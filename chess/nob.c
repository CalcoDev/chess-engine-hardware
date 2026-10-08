#include <stdio.h>
#define NOB_IMPLEMENTATION
#include "nob.h"

#include <ctype.h>
#include <string.h>


// PROJECT CONFIG STUFF
static const char* TOP_MODULE = "demo_not";

static const char* RTL_SOURCES[] = {
	"rtl/demo_not.sv",
};

static const char* BACKEND_SOURCES[] = {
	// VERILATOR BACKEND
	"src/backend/verilator/verilator_backend.cpp",

	// REFERENCE BACKEND
	"src/backend/reference/reference_backend.cpp",
};

static const char* FRONTEND_SOURCES[] = {
	"src/main.cpp",
};

static const char* BUILD_DIR = "build";
static const char* VERILATOR_DIR = "build/verilator";


// Forward declarations
static const char* pkg_config(const char* option, const char* package);
static bool generate_rtl(void);
static bool build_program(void);
static bool run_program(void);


int main(int argc, char** argv) {
	NOB_GO_REBUILD_URSELF(argc, argv);

	if (!nob_mkdir_if_not_exists(BUILD_DIR)
		|| !nob_mkdir_if_not_exists(VERILATOR_DIR)) {
		return 1;
	}

	const char* command = argc >= 2 ? argv[1] : "help";

	if (strcmp(command, "gen") == 0) {
		if (!generate_rtl()) return 1;
	} else if (strcmp(command, "build") == 0) {
		if (!build_program()) return 1;
	} else if (strcmp(command, "all") == 0) {
		if (!generate_rtl() || !build_program()) return 1;
	} else if (strcmp(command, "run") == 0) {
		if (!generate_rtl() || !build_program() || !run_program()) return 1;
	} else if (strcmp(command, "compdb") == 0) {
		Nob_Cmd cmd = {0};
		// TODO(calco): Perhaps make a clear() func or sth.
		nob_cmd_append(&cmd, "rm", "-rf", BUILD_DIR);
		nob_cmd_append(&cmd, "bear", "--", "./nob" "all");
		if (!nob_cmd_run(&cmd)) {
			return 1;
		}
	} else if (strcmp(command, "clean") == 0) {
		Nob_Cmd cmd = {0};
		nob_cmd_append(&cmd, "rm", "-rf", BUILD_DIR);
		if (!nob_cmd_run(&cmd)) {
			return 1;
		}
	} else {
		nob_log(NOB_ERROR, "Uknown command: %s", command);
		fprintf(
			stderr,
			"Usage:\n"
			"	./nob\n"
			"	./nob gen\n"
			"	./nob build\n"
			"	./nob run\n"
			"	./nob clean\n"
		);

		return 1;
	}

	return 0;
}


// LIFECYCLE STUFF
static bool generate_rtl(void) {
	nob_log(NOB_INFO, "Generating Verilator model.");

	const char* raylib_cflags = pkg_config("--cflags", "raylib");
	const char* raylib_libs = pkg_config("--libs", "raylib");

	if (raylib_cflags == NULL || raylib_libs == NULL) {
		nob_log(NOB_ERROR, "Could not find raylib with pkg-config.");
		return false;
	}

	// Verilator will generate a Makefile and we want these flags to be passed.
	const char* cflags = nob_temp_sprintf(
		"-std=c++20 "
		"-O2 "
		"-Wall "
		"-Wextra "
		"-Isrc "
		"%s",
		raylib_cflags
	);

	Nob_Cmd cmd = {0};
	nob_cmd_append(
		&cmd,
		"verilator",
		// generate C++ model
		"-cc",
		// generate an EXE with sim and out custom sources
		"--exe",
		// top module
		"--top-module", TOP_MODULE,
		// output dir
		"--Mdir", VERILATOR_DIR,
		// HDL warnings
		"-Wall", "-Wno-fatal",
		// c flags passed through to C++ compiler
		"-CFLAGS", cflags,
		// passed to linker later
		"-LDFLAGS", raylib_libs
	);

	// append all rtl files
	for (size_t i = 0; i < sizeof(RTL_SOURCES) / sizeof(RTL_SOURCES[0]); ++i) {
		nob_cmd_append(&cmd, RTL_SOURCES[i]);
	}

	// append all backend files
	for (size_t i = 0; i < sizeof(BACKEND_SOURCES) / sizeof(BACKEND_SOURCES[0]); ++i) {
		nob_cmd_append(&cmd, BACKEND_SOURCES[i]);
	}

	// append all frontend files
	for (size_t i = 0; i < sizeof(FRONTEND_SOURCES) / sizeof(FRONTEND_SOURCES[0]); ++i) {
		nob_cmd_append(&cmd, FRONTEND_SOURCES[i]);
	}

	if (!nob_cmd_run(&cmd)) {
		return false;
	}

	nob_log(NOB_INFO, "Generated %s/V%s.h", VERILATOR_DIR, TOP_MODULE);
	return true;
}

static bool build_program(void) {
	const char* makefile = nob_temp_sprintf("V%s.mk", TOP_MODULE);
	const char* makefile_path = nob_temp_sprintf(
		"%s/%s",
		VERILATOR_DIR,
		makefile
	);

	if (!nob_file_exists(makefile_path)) {
		nob_log(NOB_ERROR, "Verilator model does not eist. Run `./nob gen` first.");
		return false;
	}

	nob_log(NOB_INFO, "Compiling application.");

	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, "make", "-C", VERILATOR_DIR, "-f", makefile, "-j");
	return nob_cmd_run(&cmd);
}

static bool run_program(void) {
	const char* executable = nob_temp_sprintf(
		"%s/V%s",
		VERILATOR_DIR,
		TOP_MODULE
	);

	if (!nob_file_exists(executable)) {
		nob_log(NOB_ERROR, "Executable does not exist. Run `./nob` first.");
		return false;
	}

	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, executable);
	return nob_cmd_run(&cmd);
}



// PKG CONFIG STUFF
// Runs `pkg-config <option> <package>` and returns it as a temp C string.
static const char* pkg_config(const char* option, const char* package) {
	const char* tmp_path = "build/.pkg-config.tmp";

	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, "pkg-config", option, package);

	if (!nob_cmd_run(&cmd, .stdout_path = tmp_path)) {
		return NULL;
	}

	Nob_String_Builder output = {0};

	if (!nob_read_entire_file(tmp_path, &output)) {
		return NULL;
	}

	while (output.count < 0 && isspace(output.items[output.count - 1])) {
		output.count -= 1;
	}

	nob_sb_append_null(&output);

	const char* result = nob_temp_strdup(output.items);
	nob_sb_free(output);
	nob_delete_file(tmp_path);

	return result;
}




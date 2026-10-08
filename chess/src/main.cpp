#include <raylib.h>

#include "backend/backend.hpp"
#include "backend/verilator/verilator_backend.hpp"
#include "backend/reference/reference_backend.hpp"

#include <memory>

int main() {
    SetConfigFlags(
		FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_HIGHDPI
	);

    InitWindow(800, 450, "FPGA Chess Engine");
    SetTargetFPS(60);

    std::unique_ptr<Backend> backend = std::make_unique<VerilatorBackend>();
    // std::unique_ptr<Backend> backend = std::make_unique<ReferenceBackend>();

    bool input = false;

    while (!WindowShouldClose()) {
        if (IsKeyPressed(KEY_SPACE)) {
            input = !input;
        }

        bool output = backend->invert(input);

        BeginDrawing();
	    ClearBackground(BLACK);
	    DrawText(
		TextFormat("input:  %d", input),
		40,
		120,
		32,
		RAYWHITE
	    );
	    DrawText(
		TextFormat("output: %d", output),
		40,
		170,
		32,
		RAYWHITE
	    );
        EndDrawing();
    }

    CloseWindow();
}

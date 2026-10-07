#include <stdio.h>

#include <raylib.h>

#include "rtl_backend.hpp"

int main() {
	printf("Hello world from chess engine!");

	SetConfigFlags(FLAG_WINDOW_RESIZABLE | FLAG_WINDOW_HIGHDPI);

	InitWindow(800, 450, "Chess Engine thingamabob");
	SetTargetFPS(240);

	RtlBackend backend;

	bool input = false;

	while (!WindowShouldClose()) {
		if (IsKeyPressed(KEY_SPACE)) {
			input = !input;
		}

		bool output = backend.invert(input);

		BeginDrawing();
		ClearBackground(Color{20, 20, 24, 255});

		DrawText(
			TextFormat("input wire: %d", input),
			40, 160, 30,
			input ? GREEN : RED
		);
		
		DrawText(
			TextFormat("output wire: %d", output),
			40, 260, 30,
			output ? GREEN : RED
		);
		EndDrawing();
	}

	CloseWindow();
	return 0;
}


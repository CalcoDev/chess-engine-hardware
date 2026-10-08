# Chess

The actual chess implementation for (entire goal of project). Idk why we have
this as a separate folder, guess I thought this looked better.

## Build System

Using [nob.h](https://github.com/tsoding/nob.h) by Tsoding for 3 simple reasons:
- I like writing C.
- I dislike writing bash.
- I have no clue how CMake works.
- also because it's a really simple build, frankly we just pass flags around to
  Verilator and back, but whatever.

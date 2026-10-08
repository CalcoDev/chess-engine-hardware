# FPGA Engine Thingy

So this is my playhround for properly learning System Verilog and system design.

Will go from basics to hopefully a small chess engine thingy, a cpu gpu pair, 
and then some fantasy console N64 bs.

## Playground

A place with a bunch of experiments for diff things.

## Chess

The actual chess related parts of this repo. Will probably be represented by a
C(++)* + Raylib frontend, and 2 different backends:
- Simulated RTL using Verilator (why we need C++, as it generated cpp, but I
will be writing C style code.) = debug mode
- Actual physical hardware FPGA once uploaded. Of course, at that point
switching to purely physical device would be ideal but still.

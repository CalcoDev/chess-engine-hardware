`timescale 1ns / 1ps

module binary_to_bcd_tb;

    localparam int BIN_WIDTH = 8;

    reg clk;
    reg reset;
    reg start;

    reg [BIN_WIDTH-1:0] binary_in;

    wire [4 * ((BIN_WIDTH + 2) / 3) - 1:0] bcd_out;
    wire busy;
    wire done;

    binary_to_bcd #(
        .BIN_WIDTH(BIN_WIDTH)
    ) dut (
        .clk      (clk),
        .reset    (reset),
        .start    (start),
        .binary_in(binary_in),
        .bcd_out  (bcd_out),
        .busy     (busy),
        .done     (done)
    );

    // 100 MHz clock
    initial clk = 1'b0;

    always #5 clk = ~clk;

    initial begin
        reset = 1'b1;
        start = 1'b0;
        binary_in = '0;

        // hold reset
        repeat (2) @(posedge clk);

        reset = 1'b0;

        // test 13
        binary_in = 8'd13;

        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b1;

        @(posedge clk);
        start = 1'b0;

        // wait for convert
        wait (done);

        $display("binary = %0d", binary_in);
        $display("bcd raw = %h", bcd_out);

        repeat (2) @(posedge clk);

        $finish;
    end

endmodule

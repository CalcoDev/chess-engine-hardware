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
        $dumpfile("binary_to_bcd.fst");
        $dumpvars(0, binary_to_bcd_tb);
    end

    initial begin
        reset = 1'b1;
        start = 1'b0;
        binary_in = '0;

        // hold reset
        repeat (2) @(posedge clk);
        reset = 1'b0;

        test_value(8'd0, 12'h000);
        test_value(8'd7, 12'h007);
        test_value(8'd13, 12'h013);
        test_value(8'd42, 12'h042);
        test_value(8'd99, 12'h099);
        test_value(8'd255, 12'h255);

        $finish;
    end

    task test_value(input [BIN_WIDTH-1:0] value, input [11:0] expected);
        begin
            binary_in = value;

            @(posedge clk);
            start = 1'b1;

            @(posedge clk);
            start = 1'b0;

            wait (done);

            if (bcd_out !== expected) begin
                $display("FAIL: input=%0d expected=%h got=%h", value, expected, bcd_out);
            end else begin
                $display("PASS: input=%0d -> BCD=%h", value, bcd_out);
            end

            @(posedge clk);
        end
    endtask

endmodule

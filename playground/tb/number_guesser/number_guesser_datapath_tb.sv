`timescale 1ns / 1ps

module number_guesser_datapath_tb;

    localparam int unsigned WIDTH = 8;

    logic clk = 1'b0;

    logic init;
    logic update_low;
    logic update_high;

    wire [WIDTH-1:0] low;
    wire [WIDTH-1:0] high;
    wire [WIDTH-1:0] guess;


    number_guesser_datapath #(
        .WIDTH(WIDTH)
    ) dut (
        .clk(clk),

        .init       (init),
        .update_low (update_low),
        .update_high(update_high),

        .low  (low),
        .high (high),
        .guess(guess)
    );


    always #5 clk = ~clk;


    task automatic check_state(input logic [WIDTH-1:0] expected_low,
                               input logic [WIDTH-1:0] expected_high,
                               input logic [WIDTH-1:0] expected_guess, input string name);
        #1;

        if (low !== expected_low || high !== expected_high || guess !== expected_guess) begin
            $fatal(1, "%s FAILED: low=%0d high=%0d guess=%0d; expected %0d %0d %0d", name, low,
                   high, guess, expected_low, expected_high, expected_guess);
        end

        $display("%s PASS: low=%0d high=%0d guess=%0d", name, low, high, guess);
    endtask


    initial begin
        $dumpfile("number_guesser_datapath.fst");
        $dumpvars(0, number_guesser_datapath_tb);

        init        = 1'b1;
        update_low  = 1'b0;
        update_high = 1'b0;


        // -------------------------------------------------
        // INITIALISE
        //
        // First clock writes:
        //
        // low  = 0
        // high = 255
        // -------------------------------------------------

        @(posedge clk);

        init = 1'b0;

        check_state(8'd0, 8'd255, 8'd127, "initialise");


        // -------------------------------------------------
        // User said HIGHER to 127
        //
        // low = 127 + 1 = 128
        //
        // midpoint:
        // (128 + 255) / 2 = 191
        // -------------------------------------------------

        update_low = 1'b1;

        @(posedge clk);

        update_low = 1'b0;

        check_state(8'd128, 8'd255, 8'd191, "higher after 127");


        // -------------------------------------------------
        // User said LOWER to 191
        //
        // high = 191 - 1 = 190
        //
        // guess = (128 + 190) / 2 = 159
        // -------------------------------------------------

        update_high = 1'b1;

        @(posedge clk);

        update_high = 1'b0;

        check_state(8'd128, 8'd190, 8'd159, "lower after 191");


        // -------------------------------------------------
        // Higher than 159
        // -------------------------------------------------

        update_low = 1'b1;

        @(posedge clk);

        update_low = 1'b0;

        check_state(8'd160, 8'd190, 8'd175, "higher after 159");


        // -------------------------------------------------
        // Lower than 175
        // -------------------------------------------------

        update_high = 1'b1;

        @(posedge clk);

        update_high = 1'b0;

        check_state(8'd160, 8'd174, 8'd167, "lower after 175");


        // -------------------------------------------------
        // Neither update asserted:
        // registers must retain their values.
        // -------------------------------------------------

        @(posedge clk);

        check_state(8'd160, 8'd174, 8'd167, "register hold");


        $display("DATAPATH TESTS PASSED");
        $finish;
    end

endmodule

`timescale 1ns / 1ps

module number_guesser_control_tb;

    logic clk = 1'b0;
    logic reset;

    logic higher;
    logic lower;
    logic correct;

    wire  init;
    wire  update_low;
    wire  update_high;
    wire  done;

    number_guesser_control dut (
        .clk  (clk),
        .reset(reset),

        .higher (higher),
        .lower  (lower),
        .correct(correct),

        .init       (init),
        .update_low (update_low),
        .update_high(update_high),
        .done       (done)
    );

    // 10ns clock period
    always #5 clk = ~clk;

    task automatic check_outputs(input logic expected_init, input logic expected_update_low,
                                 input logic expected_update_high, input logic expected_done,
                                 input string name);
        #1;

        if (init !== expected_init ||
            update_low !== expected_update_low ||
            update_high !== expected_update_high ||
            done !== expected_done
        ) begin
            $fatal(1, "%s FAILED: got init=%b low%b high%b done%b", name, init, update_low,
                   update_high, done);
        end

        $display("%s PASS", name);
    endtask


    initial begin
        $dumpfile("number_guesser_control.fst");
        $dumpvars(0, number_guesser_control_tb);

        reset   = 1'b1;
        higher  = 1'b0;
        lower   = 1'b0;
        correct = 1'b0;


        // -------------------------------------------------
        // RESET -> INIT
        // -------------------------------------------------

        @(posedge clk);

        check_outputs(1'b1, 1'b0, 1'b0, 1'b0, "reset enters INIT");


        // -------------------------------------------------
        // INIT -> RUNNING
        // -------------------------------------------------

        reset = 1'b0;

        @(posedge clk);

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "INIT enters RUNNING");


        // -------------------------------------------------
        // HIGHER
        //
        // This is combinational control, so we don't
        // need another clock edge to see update_low.
        // -------------------------------------------------

        higher = 1'b1;

        check_outputs(1'b0, 1'b1, 1'b0, 1'b0, "higher");

        higher = 1'b0;


        // -------------------------------------------------
        // LOWER
        // -------------------------------------------------

        lower  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b1, 1'b0, "lower");

        lower  = 1'b0;


        // -------------------------------------------------
        // HIGHER + LOWER simultaneously
        //
        // Your controller deliberately ignores this.
        // -------------------------------------------------

        higher = 1'b1;
        lower  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "higher and lower simultaneously");

        higher  = 1'b0;
        lower   = 1'b0;


        // -------------------------------------------------
        // CORRECT suppresses update signals
        // -------------------------------------------------

        correct = 1'b1;
        higher  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "correct overrides higher");


        // -------------------------------------------------
        // RUNNING -> DONE
        // -------------------------------------------------

        higher = 1'b0;

        @(posedge clk);

        correct = 1'b0;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b1, "correct enters DONE");


        // -------------------------------------------------
        // DONE stays DONE and ignores commands
        // -------------------------------------------------

        higher = 1'b1;

        @(posedge clk);

        check_outputs(1'b0, 1'b0, 1'b0, 1'b1, "DONE is absorbing");


        $display("CONTROLLER TESTS PASSED");
        $finish;
    end

endmodule

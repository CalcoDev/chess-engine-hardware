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


    // 10 ns clock period
    always #5 clk = ~clk;


    task automatic check_outputs(input logic expected_init, input logic expected_update_low,
                                 input logic expected_update_high, input logic expected_done,
                                 input string name);
        // Let combinational logic / NBA updates settle.
        #1;

        if (
            init        !== expected_init        ||
            update_low  !== expected_update_low  ||
            update_high !== expected_update_high ||
            done        !== expected_done
        ) begin
            $fatal(
                1,
                "%s FAILED: got init=%b update_low=%b update_high=%b done=%b; expected init=%b update_low=%b update_high=%b done=%b",
                name, init, update_low, update_high, done, expected_init, expected_update_low,
                expected_update_high, expected_done);
        end

        $display("%s PASS", name);
    endtask


    initial begin
        $dumpfile("number_guesser_control.fst");
        $dumpvars(0, number_guesser_control_tb);


        // -------------------------------------------------
        // Initial inputs
        // -------------------------------------------------

        reset   = 1'b1;
        higher  = 1'b0;
        lower   = 1'b0;
        correct = 1'b0;


        // -------------------------------------------------
        // RESET -> INIT
        //
        // reset is synchronous in our structural register,
        // so the state register sees it on this posedge.
        // -------------------------------------------------

        @(posedge clk);

        check_outputs(1'b1, 1'b0, 1'b0, 1'b0, "reset enters INIT");


        // -------------------------------------------------
        // INIT -> RUNNING
        //
        // Release reset away from the active clock edge.
        // -------------------------------------------------

        @(negedge clk);
        reset = 1'b0;

        @(posedge clk);

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "INIT enters RUNNING");


        // -------------------------------------------------
        // HIGHER
        //
        // update_low is combinational while RUNNING.
        // -------------------------------------------------

        @(negedge clk);

        higher = 1'b1;

        check_outputs(1'b0, 1'b1, 1'b0, 1'b0, "higher");


        // -------------------------------------------------
        // LOWER
        // -------------------------------------------------

        @(negedge clk);

        higher = 1'b0;
        lower  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b1, 1'b0, "lower");


        // -------------------------------------------------
        // HIGHER + LOWER simultaneously
        //
        // Controller deliberately rejects an ambiguous
        // direction.
        // -------------------------------------------------

        @(negedge clk);

        higher = 1'b1;
        lower  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "higher and lower simultaneously");


        // -------------------------------------------------
        // CORRECT has priority
        //
        // Even if higher is asserted, no datapath update
        // should be requested when correct is asserted.
        // -------------------------------------------------

        @(negedge clk);

        higher  = 1'b1;
        lower   = 1'b0;
        correct = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b0, "correct overrides higher");


        // -------------------------------------------------
        // RUNNING -> DONE
        //
        // Keep correct asserted THROUGH the rising edge.
        // -------------------------------------------------

        @(posedge clk);

        check_outputs(1'b0, 1'b0, 1'b0, 1'b1, "correct enters DONE");


        // Remove inputs safely after the sampling edge.
        @(negedge clk);

        higher  = 1'b0;
        lower   = 1'b0;
        correct = 1'b0;


        // -------------------------------------------------
        // DONE is absorbing
        // -------------------------------------------------

        higher  = 1'b1;

        check_outputs(1'b0, 1'b0, 1'b0, 1'b1, "DONE ignores higher");

        @(posedge clk);

        check_outputs(1'b0, 1'b0, 1'b0, 1'b1, "DONE remains DONE");


        // -------------------------------------------------
        // RESET from DONE
        // -------------------------------------------------

        @(negedge clk);

        higher = 1'b0;
        reset  = 1'b1;

        @(posedge clk);

        check_outputs(1'b1, 1'b0, 1'b0, 1'b0, "reset DONE back to INIT");


        $display("");
        $display("ALL CONTROLLER TESTS PASSED");
        $finish;
    end

endmodule

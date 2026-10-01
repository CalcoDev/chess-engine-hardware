module counter_tb;

    logic clk = 0;
    logic reset = 1;

    logic [3:0] count;

    counter dut (
        .clk  (clk),
        .reset(reset),
        .count(count)
    );

    // Fake clock:
    always #5 clk = ~clk;

    initial begin

        // Keep reset active for a couple clock edges.
        repeat (2) @(posedge clk);

        reset = 0;

        repeat (10) @(posedge clk);

        $finish;
    end

    always @(posedge clk) begin
        $display("time=%0t reset=%b count=%0d", $time, reset, count);
    end

endmodule

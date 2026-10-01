module adder_tb;

    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] result;

    adder dut (
        .a(a),
        .b(b),
        .result(result)
    );

    initial begin
        a = 10;
        b = 20;

        #1;

        $display("%0d + %0d = %0d", a, b, result);

        if (result != 30) $fatal("Adder broken!");

        $finish;
    end

endmodule

module reg_reset_n #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire [WIDTH-1:0] d,
    input wire [WIDTH-1:0] q
);

    wire [WIDTH-1:0] next_q;

    mux_bus #(
        .WIDTH(WIDTH)
    ) load_mux (
        .a(d),
        .b('0),
        .s(reset),
        .y(next_q)
    );

    reg_n #(
        .WIDTH(WIDTH)
    ) reg_n (
        .clk(clk),
        .d  (next_q),
        .q  (q)
    );

endmodule

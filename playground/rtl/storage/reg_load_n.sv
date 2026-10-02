module reg_load_n #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,
    input wire load,
    input wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] q
);

    wire [WIDTH-1:0] next_q;

    mux_bus #(
        .WIDTH(WIDTH)
    ) load_mux (
        .a(q),
        .b(d),
        .s(load),
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

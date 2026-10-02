// reset load | next q
// -----------+-------
//   1    X   | 0
//   0    1   | d
//   0    0   | old q

// yes, we did just reimplement a weird
// always_ff @(posedge clk) begin
//      if (reset)
//          q <= '0;
//      else if (load)
//          q <= d;
//  end

module reg_load_reset_n #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [WIDTH-1:0] d,
    output wire [WIDTH-1:0] q
);

    wire [WIDTH-1:0] load_q;
    wire [WIDTH-1:0] next_q;

    mux_bus #(
        .WIDTH(WIDTH)
    ) load_bus (
        .a(d),
        .b(q),
        .s(load),
        .y(load_q)
    );

    mux_bus #(
        .WIDTH(WIDTH)
    ) reset_bus (
        .a(load_q),
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

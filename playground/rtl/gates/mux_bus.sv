module mux_bus #(
    parameter int unsigned WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire s,
    output wire [WIDTH-1:0] y
);

    genvar i;

    generate
        for (i = 0; i < WIDTH; i++) begin : gen_mux
            mux2 m (
                .a(a[i]),
                .b(b[i]),
                .s(s),
                .y(y[i])
            );
        end
    endgenerate

endmodule

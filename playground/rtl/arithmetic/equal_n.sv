module equal_n #(
    parameter int unsigned WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output wire equal
);

    wire [WIDTH-1:0] bit_equal;
    wire [  WIDTH:0] chain;

    assign chain[0] = 1'b1;
    assign equal = chain[WIDTH];

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_compare_eq
            xnor2 xnor_gate (
                .a(a[i]),
                .b(b[i]),
                .y(bit_equal[i])
            );

            and2 chain_gate (
                .a(chain[i]),
                .b(bit_equal[i]),
                .y(chain[i+1])
            );
        end
    endgenerate

endmodule

module less_than_unsigned #(
    parameter int unsigned WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output wire less
);

    wire [WIDTH:0] less_chain;
    assign less_chain[0] = 1'b0;
    assign less = less_chain[WIDTH];


    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_compare_lt
            wire a_not;
            wire bit_less;
            wire bit_equal;
            wire bit_equal_and_lower_less;

            not1 n0 (
                .a(a[i]),
                .y(a_not)
            );

            and2 a0 (
                .a(a_not),
                .b(b[i]),
                .y(bit_less)
            );

            xnor2 x0 (
                .a(a[i]),
                .b(b[i]),
                .y(bit_equal)
            );

            and2 a1 (
                .a(bit_equal),
                .b(less_chain[i]),
                .y(bit_equal_and_lower_less)
            );

            or2 o0 (
                .a(bit_less),
                .b(bit_equal_and_lower_less),
                .y(less_chain[i+1])
            );

        end
    endgenerate

endmodule

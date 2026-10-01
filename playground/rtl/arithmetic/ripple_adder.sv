module ripple_adder #(
    parameter int unsigned WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire carry_in,
    output wire [WIDTH-1:0] sum,
    output wire carry_out
);

    // 1 extra storage as we have c_in + WIDTH-1 carries
    wire [WIDTH:0] carry;
    assign carry[0]  = carry_in;
    assign carry_out = carry[WIDTH];

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_adder
            full_adder fa (
                .a        (a[i]),
                .b        (b[i]),
                .carry_in (carry[i]),
                .sum      (sum[i]),
                .carry_out(carry[i+1])
            );
        end
    endgenerate

endmodule

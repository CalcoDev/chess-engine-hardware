module full_adder (
    input wire a,
    input wire b,
    input wire carry_in,

    output wire sum,
    output wire carry_out
);

    wire s0;
    wire c0;
    wire c1;

    half_adder ha0 (
        .a    (a),
        .b    (b),
        .sum  (s0),
        .carry(c0)
    );

    half_adder ha1 (
        .a    (s0),
        .b    (carry_in),
        .sum  (sum),
        .carry(c1)
    );

    or2 carry_gate (
        .a(c0),
        .b(c1),
        .y(carry_out)
    );

endmodule

module half_adder (
    input  wire a,
    input  wire b,
    output wire sum,
    output wire carry
);

    xor2 sum_gate (
        .a(a),
        .b(b),
        .y(sum)
    );

    and2 carry_gate (
        .a(a),
        .b(b),
        .y(carry)
    );


endmodule

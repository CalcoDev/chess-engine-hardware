module xnor2 (
    input  wire a,
    input  wire b,
    output wire y
);

    wire x;

    xor2 x1 (
        .a(a),
        .b(b),
        .y(x)
    );

    not1 n1 (
        .a(x),
        .y(y)
    );

endmodule

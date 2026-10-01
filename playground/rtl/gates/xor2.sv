module xor2 (
    input  wire a,
    input  wire b,
    output wire y
);

    wire n0;
    wire n1;
    wire n2;

    nand2 g0 (
        .a(a),
        .b(b),
        .y(n0)
    );


    nand2 g1 (
        .a(a),
        .b(n0),
        .y(n1)
    );

    nand2 g2 (
        .a(b),
        .b(n0),
        .y(n2)
    );


    nand2 g3 (
        .a(n1),
        .b(n2),
        .y(y)
    );

endmodule

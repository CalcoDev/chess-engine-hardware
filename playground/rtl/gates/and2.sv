module and2 (
    input  wire a,
    input  wire b,
    output wire y
);

    wire na;

    nand2 nand2 (
        .a(a),
        .b(b),
        .y(na)
    );

    not1 not1 (
        .a(na),
        .y(y)
    );

endmodule

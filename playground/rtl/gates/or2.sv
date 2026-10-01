module or2 (
    input  wire a,
    input  wire b,
    output wire y
);

    wire na;
    wire nb;

    not1 n0 (
        .a(a),
        .y(na)
    );

    not1 n1 (
        .a(b),
        .y(nb)
    );

    nand2 n2 (
        .a(na),
        .b(nb),
        .y(y)
    );

endmodule

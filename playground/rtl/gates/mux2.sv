module mux2 (
    input  wire a,
    input  wire b,
    input  wire s,
    output wire y
);

    wire ns;
    wire n0;
    wire n1;

    nand2 g0 (
        .a(s),
        .b(s),
        .y(ns)
    );

    nand2 g1 (
        .a(a),
        .b(ns),
        .y(n0)
    );

    nand2 g2 (
        .a(b),
        .b(s),
        .y(n1)
    );

    nand2 g3 (
        .a(n0),
        .b(n1),
        .y(y)
    );

endmodule

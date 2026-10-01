module not1 (
    input  wire a,
    output wire y
);

    nand2 n0 (
        .a(a),
        .b(a),
        .y(y)
    );

endmodule

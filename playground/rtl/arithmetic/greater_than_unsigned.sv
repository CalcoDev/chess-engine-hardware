module greater_than_unsigned #(
    parameter int unsigned WIDTH = 8
) (
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    output wire greater
);

    less_than_unsigned #(
        .WIDTH(WIDTH)
    ) less_than_unsigned (
        .a   (b),
        .b   (a),
        .less(greater)
    );

endmodule

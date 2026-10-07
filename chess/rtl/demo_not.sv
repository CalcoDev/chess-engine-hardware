module demo_not (
    input  wire in_value,
    output wire out_value
);

    assign out_value = ~in_value;

endmodule

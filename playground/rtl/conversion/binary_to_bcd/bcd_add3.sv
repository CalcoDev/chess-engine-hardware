module bcd_add3 (
    input  wire [3:0] digit,
    output wire [3:0] adjusted_digit_out
);

    wire digit_gt_5;
    wire [3:0] digit_plus_three;

    wire unused_carry;


    ripple_adder #(
        .WIDTH(4)
    ) add_3 (
        .a(digit),
        .b(4'b0011),
        .carry_in('0),
        .sum(digit_plus_three),
        .carry_out(unused_carry)
    );

    greater_than_unsigned #(
        .WIDTH(4)
    ) greater_than_unsigned (
        .a      (digit),
        .b      (4'b0100),
        .greater(digit_gt_5)
    );

    mux_bus #(
        .WIDTH(4)
    ) adjusted_digit_mux (
        .a(digit),
        .b(digit_plus_three),
        .s(digit_gt_5),
        .y(adjusted_digit_out)
    );



endmodule

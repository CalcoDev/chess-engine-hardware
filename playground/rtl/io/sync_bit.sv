module sync_bit (
    input wire clk,
    input wire reset,

    input  wire async_in,
    output wire sync_out
);

    wire stage1;

    reg_reset_n #(
        .WIDTH(1)
    ) sync_reg_1 (
        .clk  (clk),
        .reset(reset),
        .d    (async_in),
        .q    (stage1)
    );

    reg_reset_n #(
        .WIDTH(1)
    ) sync_reg_2 (
        .clk  (clk),
        .reset(reset),
        .d    (stage1),
        .q    (sync_out)
    );

endmodule

module double_dabble_datapath #(
    parameter int unsigned BIN_WIDTH = 8
) (
    input wire clk,
    input wire reset,

    input wire load,
    input wire step,

    input wire [BIN_WIDTH-1:0] binary_in,
    output wire [4 * ((BIN_WIDTH + 2) / 3) - 1:0] bcd_out
);

    localparam int BCD_DIGITS = (BIN_WIDTH + 2) / 3;
    localparam int BCD_WIDTH  = BCD_DIGITS * 4;

    wire [BIN_WIDTH-1:0] bin_q;
    wire [BIN_WIDTH-1:0] bin_d;

    wire [BCD_WIDTH-1:0] bcd_q;
    wire [BCD_WIDTH-1:0] bcd_d;

    wire [BCD_WIDTH-1:0] bcd_adjusted;

    wire [BIN_WIDTH-1:0] bin_shifted;
    wire [BCD_WIDTH-1:0] bcd_shifted;

    wire [BIN_WIDTH-1:0] bin_step_data;
    wire [BCD_WIDTH-1:0] bcd_step_data;


    // >=5 => *3
    genvar i;
    generate
        for (i = 0; i < BCD_DIGITS; i++) begin : gen_bcd_add3
            bcd_add3 bcd_add3 (
                .digit             (bcd_q[i*4+:4]),
                .adjusted_digit_out(bcd_adjusted[i*4+:4])
            );
        end
    endgenerate


    // Do the shift
    assign bin_shifted = {bin_q[BIN_WIDTH-2:0], 1'b0};
    assign bcd_shifted = {bcd_adjusted[BCD_WIDTH-2:0], bin_q[BIN_WIDTH-1]};


    // Now I need to actually load stuff lmfao
    mux_bus #(
        .WIDTH(BIN_WIDTH)
    ) bin_step_mux (
        .a(bin_q),
        .b(bin_shifted),
        .s(step),
        .y(bin_step_data)
    );

    mux_bus #(
        .WIDTH(BIN_WIDTH)
    ) bin_d_mux (
        .a(bin_step_data),
        .b(binary_in),
        .s(load),
        .y(bin_d)
    );


    mux_bus #(
        .WIDTH(BCD_WIDTH)
    ) bcd_step_mux (
        .a(bcd_q),
        .b(bcd_shifted),
        .s(step),
        .y(bcd_step_data)
    );

    mux_bus #(
        .WIDTH(BCD_WIDTH)
    ) bcd_d_mux (
        .a(bcd_step_data),
        .b('0),
        .s(load),
        .y(bcd_d)
    );


    // Storage stuff
    reg_reset_n #(
        .WIDTH(BIN_WIDTH)
    ) binary_reg (
        .clk  (clk),
        .reset(reset),
        .d    (bin_d),
        .q    (bin_q)
    );

    reg_reset_n #(
        .WIDTH(BCD_WIDTH)
    ) bcd_reg (
        .clk  (clk),
        .reset(reset),
        .d    (bcd_d),
        .q    (bcd_q)
    );

    assign bcd_out = bcd_q;

endmodule

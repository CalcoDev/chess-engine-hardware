module binary_to_bcd #(
    parameter int unsigned BIN_WIDTH = 8
) (
    input wire clk,
    input wire reset,

    input wire start,

    input wire [BIN_WIDTH-1:0] binary_in,

    output wire [4 * ((BIN_WIDTH + 2) / 3) - 1:0] bcd_out,
    output wire busy,
    output wire done
);

    wire load;
    wire step;


    double_dabble_control #(
        .BIN_WIDTH(BIN_WIDTH)
    ) control (
        .clk  (clk),
        .reset(reset),
        .start(start),
        .load (load),
        .step (step),
        .busy (busy),
        .done (done)
    );

    double_dabble_datapath #(
        .BIN_WIDTH(BIN_WIDTH)
    ) datapath (
        .clk      (clk),
        .reset    (reset),
        .load     (load),
        .step     (step),
        .binary_in(binary_in),
        .bcd_out  (bcd_out)
    );

endmodule

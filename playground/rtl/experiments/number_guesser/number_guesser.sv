module number_guesser #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,
    input wire reset,

    input wire higher,
    input wire lower,
    input wire correct,

    output wire [WIDTH-1:0] low,
    output wire [WIDTH-1:0] high,
    output wire [WIDTH-1:0] guess,

    output wire done
);

    // Control-path -> datapath
    wire init;
    wire update_low;
    wire update_high;


    number_guesser_control control (
        .clk  (clk),
        .reset(reset),

        .higher (higher),
        .lower  (lower),
        .correct(correct),

        .init       (init),
        .update_low (update_low),
        .update_high(update_high),
        .done       (done)
    );


    number_guesser_datapath #(
        .WIDTH(WIDTH)
    ) datapath (
        .clk(clk),

        .init       (init),
        .update_low (update_low),
        .update_high(update_high),

        .low  (low),
        .high (high),
        .guess(guess)
    );

endmodule

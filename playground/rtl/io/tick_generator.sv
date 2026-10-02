// NOTE(calco): The Tang Nano 20k has a 27MHz clock, hence this default value.
module tick_generator #(
    parameter int unsigned PERIOD = 27_000
) (
    input wire clk,
    input wire reset,

    output wire tick
);

    localparam int unsigned COUNTER_WIDTH = (PERIOD <= 1) ? 1 : $clog2(PERIOD);
    localparam logic [COUNTER_WIDTH-1:0] LAST = COUNTER_WIDTH'(PERIOD - 1);

    wire [COUNTER_WIDTH-1:0] count_d;
    wire [COUNTER_WIDTH-1:0] count_q;

    wire [COUNTER_WIDTH-1:0] count_plus_one;

    wire carry_unused;

    wire terminal;
    assign tick = terminal;

    ripple_adder #(
        .WIDTH(COUNTER_WIDTH)
    ) incrementer (
        .a        (count_q),
        .b        ('0),
        .carry_in (1'b1),
        .sum      (count_plus_one),
        .carry_out(carry_unused)
    );

    equal_n #(
        .WIDTH(COUNTER_WIDTH)
    ) terminal_compare (
        .a    (count_q),
        .b    (LAST),
        .equal(terminal)
    );

    mux_bus #(
        .WIDTH(COUNTER_WIDTH)
    ) next_count_mux (
        .a(count_plus_one),
        .b('0),
        .s(terminal),
        .y(count_d)
    );


    reg_reset_n #(
        .WIDTH(COUNTER_WIDTH)
    ) reg_reset_n (
        .clk  (clk),
        .reset(reset),
        .d    (count_d),
        .q    (count_q)
    );

endmodule

// NOTE(calco): Assuming this will be hooked to a tick_generator, not actual
// base clock. If base clock ig multiply 1 stable tick by 27_000 or whatever
// ur actual clock is lol
//
// NOTE(calco): CORRECTION!
// This is NOT how this is supposed to work! We will keep normal clock and just
// use tick signal specially for sync stuff. Clock domain crossing is ... bad.
module debouncer #(
    parameter int unsigned STABLE_TICKS = 4
) (
    input wire clk,
    input wire reset,
    input wire tick,

    input  wire noisy_in,
    output wire clean_out
);

    localparam TICK_COUNT_WIDTH = (STABLE_TICKS <= 1) ? 1 : $clog2(STABLE_TICKS);
    localparam TICK_LAST = TICK_COUNT_WIDTH'(STABLE_TICKS - 1);

    wire [TICK_COUNT_WIDTH-1:0] count_d;
    wire [TICK_COUNT_WIDTH-1:0] count_q;

    wire [TICK_COUNT_WIDTH-1:0] count_plus_one;

    wire clean_d;

    wire not_input_changed;
    wire count_done;

    wire carry_unused;

    wire [TICK_COUNT_WIDTH-1:0] next_count_intermediary;

    wire clean_d_mux_select;
    wire not_not_input_changed;

    // clock sync with tick
    wire [TICK_COUNT_WIDTH-1:0] sampled_count_d;
    wire sampled_clean_d;

    // Compute next clean_d
    // clean_d = (count_done AND NOT not_input_changed) ? noisy_in : clean_out
    not1 not_not_input_changed_not (
        .a(not_input_changed),
        .y(not_not_input_changed)
    );

    and2 clean_d_mux_select_and (
        .a(count_done),
        .b(not_not_input_changed),
        .y(clean_d_mux_select)
    );

    mux_bus #(
        .WIDTH(1)
    ) clean_d_sample_mux (
        .a(clean_out),
        .b(noisy_in),
        .s(clean_d_mux_select),
        .y(sampled_clean_d)
    );


    // Compute next count
    // count_q = not_input_changed ? 0 : (count_done ? 0 : count + 1)
    // input_changed = noisy_in != clean_out
    // count_done = count == STABLE_TICKS - 1
    equal_n #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) count_done_compare (
        .a    (count_q),
        .b    (TICK_LAST),
        .equal(count_done)
    );

    equal_n #(
        .WIDTH(1)
    ) not_input_changed_compare (
        .a    (noisy_in),
        .b    (clean_out),
        .equal(not_input_changed)
    );

    ripple_adder #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) tick_incrementer (
        .a        (count_q),
        .b        ('0),
        .carry_in (1'b1),
        .sum      (count_plus_one),
        .carry_out(carry_unused)
    );

    mux_bus #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) next_count_intermediary_mux (
        .a(count_plus_one),
        .b('0),
        .s(count_done),
        .y(next_count_intermediary)
    );

    mux_bus #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) next_count_mux (
        .a(next_count_intermediary),
        .b('0),
        .s(not_input_changed),
        .y(sampled_count_d)
    );

    // muxes to sync on tick only
    mux_bus #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) count_tick_mux (
        .a(count_q),
        .b(sampled_count_d),
        .s(tick),
        .y(count_d)
    );

    mux_bus #(
        .WIDTH(1)
    ) clean_tick_mux (
        .a(clean_out),
        .b(sampled_clean_d),
        .s(tick),
        .y(clean_d)
    );

    // Storage stuff
    reg_reset_n #(
        .WIDTH(TICK_COUNT_WIDTH)
    ) tick_counter_reg (
        .clk  (clk),
        .reset(reset),
        .d    (count_d),
        .q    (count_q)
    );

    reg_reset_n #(
        .WIDTH(1)
    ) clean_output_reg (
        .clk  (clk),
        .reset(reset),
        .d    (clean_d),
        .q    (clean_out)
    );

endmodule

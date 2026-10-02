module double_dabble_control #(
    parameter int unsigned BIN_WIDTH = 8
) (
    input wire clk,
    input wire reset,

    input wire start,

    output wire load,
    output wire step,
    output wire busy,
    output wire done
);

    localparam int ITER_WIDTH = (BIN_WIDTH <= 1) ? 1 : $clog2(BIN_WIDTH);
    localparam logic [1:0] STATE_IDLE = 2'b00;
    localparam logic [1:0] STATE_RUN = 2'b01;
    localparam logic [1:0] STATE_DONE = 2'b10;

    localparam logic [ITER_WIDTH-1:0] ITER_LAST = ITER_WIDTH'(BIN_WIDTH - 1);

    // State storage
    wire [1:0] state_q;
    wire [1:0] state_d;

    // Iter counter storage
    wire [ITER_WIDTH-1:0] iter_q;
    wire [ITER_WIDTH-1:0] iter_d;


    // Decode current state
    wire state_is_idle;
    wire state_is_run;
    wire state_is_done;

    equal_n #(
        .WIDTH(2)
    ) idle_compare_eq (
        .a    (state_q),
        .b    (STATE_IDLE),
        .equal(state_is_idle)
    );

    equal_n #(
        .WIDTH(2)
    ) run_compare_eq (
        .a    (state_q),
        .b    (STATE_RUN),
        .equal(state_is_run)
    );

    equal_n #(
        .WIDTH(2)
    ) done_compare_eq (
        .a    (state_q),
        .b    (STATE_DONE),
        .equal(state_is_done)
    );


    // Controller outputs
    // load = IDLE & start
    and2 load_and (
        .a(state_is_idle),
        .b(start),
        .y(load)
    );

    assign step = state_is_run;
    assign busy = state_is_run;

    assign done = state_is_done;


    // Final iteration check
    wire iter_done;

    equal_n #(
        .WIDTH(ITER_WIDTH)
    ) equal_n (
        .a    (iter_q),
        .b    (ITER_LAST),
        .equal(iter_done)
    );


    // Iteration counter increment
    wire [ITER_WIDTH-1:0] iter_plus_one;
    wire iter_carry_unused;

    ripple_adder #(
        .WIDTH(ITER_WIDTH)
    ) ripple_adder (
        .a        (iter_q),
        .b        ('0),
        .carry_in (1'b1),
        .sum      (iter_plus_one),
        .carry_out(iter_carry_unused)
    );

    wire [ITER_WIDTH-1:0] iter_run_next;

    mux_bus #(
        .WIDTH(ITER_WIDTH)
    ) iter_run_mux (
        .a(iter_plus_one),
        .b('0),
        .s(iter_done),
        .y(iter_run_next)
    );

    mux_bus #(
        .WIDTH(ITER_WIDTH)
    ) iter_next_mux (
        .a('0),
        .b(iter_run_next),
        .s(state_is_run),
        .y(iter_d)
    );


    // Next state logic
    wire [1:0] idle_next;
    wire [1:0] run_next;
    wire [1:0] non_run_next;

    mux_bus #(
        .WIDTH(2)
    ) idle_next_bus (
        .a(STATE_IDLE),
        .b(STATE_RUN),
        .s(start),
        .y(idle_next)
    );

    mux_bus #(
        .WIDTH(2)
    ) run_next_bus (
        .a(STATE_RUN),
        .b(STATE_DONE),
        .s(iter_done),
        .y(run_next)
    );

    mux_bus #(
        .WIDTH(2)
    ) non_run_next_mux (
        .a(idle_next),
        .b(STATE_IDLE),
        .s(state_is_done),
        .y(non_run_next)
    );

    mux_bus #(
        .WIDTH(2)
    ) state_next_mux (
        .a(non_run_next),
        .b(run_next),
        .s(state_is_run),
        .y(state_d)
    );


    // Registers
    reg_reset_n #(
        .WIDTH(2)
    ) state_reg (
        .clk  (clk),
        .reset(reset),
        .d    (state_d),
        .q    (state_q)
    );

    reg_reset_n #(
        .WIDTH(ITER_WIDTH)
    ) iteration_reg (
        .clk  (clk),
        .reset(reset),
        .d    (iter_d),
        .q    (iter_q)
    );


endmodule

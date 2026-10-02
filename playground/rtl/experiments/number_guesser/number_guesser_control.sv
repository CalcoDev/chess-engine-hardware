module number_guesser_control (
    input wire clk,
    input wire reset,

    input wire higher,
    input wire lower,
    input wire correct,

    output wire init,
    output wire update_low,
    output wire update_high,
    output wire done
);

    // Current state
    wire [1:0] state_q;
    wire [1:0] state_d;

    // Decoding current state
    wire not_q1;
    wire not_q0;

    // wire is_init;
    wire is_running;
    // wire is_done;


    // Computing next state
    wire not_correct;
    wire running_correct;
    wire running_not_correct;


    // Update low and high
    wire not_higher;
    wire not_lower;

    wire higher_only;
    wire lower_only;

    wire running_higher;
    wire running_lower;


    // Current state
    reg_reset_n #(
        .WIDTH(2)
    ) reg_reset_n (
        .clk  (clk),
        .reset(reset),
        .d    (state_d),
        .q    (state_q)
    );


    // Decoding current state
    not1 inv_q1 (
        .a(state_q[1]),
        .y(not_q1)
    );

    not1 inv_q0 (
        .a(state_q[0]),
        .y(not_q0)
    );

    and2 decode_init (
        .a(not_q1),
        .b(not_q0),
        .y(init)
    );

    and2 decode_running (
        .a(not_q1),
        .b(state_q[0]),
        .y(is_running)
    );

    and2 decode_done (
        .a(state_q[1]),
        .b(not_q0),
        .y(done)
    );


    // Building next state
    // d[1]
    not1 inv_correct (
        .a(correct),
        .y(not_correct)
    );

    and2 running_correct_gate (
        .a(is_running),
        .b(correct),
        .y(running_correct)
    );

    or2 next_q1_gate (
        .a(done),
        .b(running_correct),
        .y(state_d[1])
    );

    // d[0]
    and2 running_not_correct_gate (
        .a(is_running),
        .b(not_correct),
        .y(running_not_correct)
    );

    or2 next_q0_gate (
        .a(init),
        .b(running_not_correct),
        .y(state_d[0])
    );


    // Update low and high
    not1 inv_higher (
        .a(higher),
        .y(not_higher)
    );

    not1 inv_lower (
        .a(lower),
        .y(not_lower)
    );


    and2 higher_only_gate (
        .a(higher),
        .b(not_lower),
        .y(higher_only)
    );

    and2 lower_only_gate (
        .a(lower),
        .b(not_higher),
        .y(lower_only)
    );


    and2 run_higher_gate (
        .a(is_running),
        .b(higher_only),
        .y(running_higher)
    );

    and2 run_lower_gate (
        .a(is_running),
        .b(lower_only),
        .y(running_lower)
    );


    and2 update_low_gate (
        .a(running_higher),
        .b(not_correct),
        .y(update_low)
    );

    and2 update_high_gate (
        .a(running_lower),
        .b(not_correct),
        .y(update_high)
    );


endmodule

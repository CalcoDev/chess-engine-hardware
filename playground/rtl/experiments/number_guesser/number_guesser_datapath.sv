module number_guesser_datapath #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,

    input wire init,
    input wire update_low,
    input wire update_high,

    output wire [WIDTH-1:0] low,
    output wire [WIDTH-1:0] high,
    output wire [WIDTH-1:0] guess
);

    wire [WIDTH-1:0] low_d;
    wire low_load;

    wire [WIDTH-1:0] high_d;
    wire high_load;


    // Midpoint calculation
    wire [WIDTH:0] low_extension;
    wire [WIDTH:0] high_extension;

    assign low_extension  = {1'b0, low};
    assign high_extension = {1'b0, high};

    wire [WIDTH:0] midpoint_sum;
    wire midpoint_carry_unused;
    wire increment_carry_unused;
    wire decrement_carry_unused;

    assign guess = midpoint_sum[WIDTH:1];


    // Guess control variations
    wire [WIDTH-1:0] guess_plus_one;
    wire [WIDTH-1:0] guess_minus_one;


    // Compute midpoint
    ripple_adder #(
        .WIDTH(WIDTH + 1)  // need to account for overflow
    ) ra_midpoint (
        .a        (low_extension),
        .b        (high_extension),
        .carry_in ('0),
        .sum      (midpoint_sum),
        .carry_out(midpoint_carry_unused)
    );


    // Guess control datapath
    ripple_adder #(
        .WIDTH(WIDTH)
    ) ra_guess_increment (
        .a        (guess),
        .b        ('0),
        .carry_in (1'b1),
        .sum      (guess_plus_one),
        .carry_out(increment_carry_unused)
    );

    ripple_adder #(
        .WIDTH(WIDTH)
    ) ra_guess_decrement (
        .a        (guess),
        .b        ('1),
        .carry_in (1'b0),
        .sum      (guess_minus_one),
        .carry_out(decrement_carry_unused)
    );


    // initialisation logic values
    mux_bus #(
        .WIDTH(WIDTH)
    ) low_d_mux (
        .a(guess_plus_one),
        .b('0),
        .s(init),
        .y(low_d)
    );

    mux_bus #(
        .WIDTH(WIDTH)
    ) high_d_mux (
        .a(guess_minus_one),
        .b('1),
        .s(init),
        .y(high_d)
    );


    // set up when high and low should be loaded
    or2 low_load_logic (
        .a(init),
        .b(update_low),
        .y(low_load)
    );

    or2 high_load_logic (
        .a(init),
        .b(update_high),
        .y(high_load)
    );


    // register data storage
    reg_load_n #(
        .WIDTH(WIDTH)
    ) low_reg (
        .clk (clk),
        .load(low_load),
        .d   (low_d),
        .q   (low)
    );

    reg_load_n #(
        .WIDTH(WIDTH)
    ) high_reg (
        .clk (clk),
        .load(high_load),
        .d   (high_d),
        .q   (high)
    );

endmodule

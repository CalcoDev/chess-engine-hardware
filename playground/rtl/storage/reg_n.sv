module reg_n #(
    parameter int unsigned WIDTH = 8
) (
    input wire clk,
    input wire [WIDTH-1:0] d,
    output logic [WIDTH-1:0] q
);

    // NOTE(calco): We are using this just to make stuff a bit more sensical
    // and not have to deal with synthesis tools weird optimisation things.
    // Still, rest of stuff is implemented fairly abstracted of this.
    always_ff @(posedge clk) begin
        q <= d;
    end

endmodule

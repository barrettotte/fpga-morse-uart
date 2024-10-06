`timescale 1ns/1ps

module baud_generator
    #(
        parameter N = 10, // counter bits; log2(651) = ~10
        parameter M = 651 // counter max; (100 * 10^6) / (9600 * 16) = ~651
    )
    (
        input wire clk_i,           // clock
        input wire reset_i,         // reset
        output wire tick_o,         // tick when counter max reached
        output wire [N-1:0] count_o // counter value
    );

    // wiring/regs
    reg [N-1:0] count_curr;
    wire [N-1:0] count_next;

    // register logic
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            count_curr <= 0;
        end else begin
            count_curr <= count_next;
        end
    end

    // next state
    assign count_next = (count_curr == (M - 1)) ? 0 : count_curr + 1;

    // output
    assign tick_o = (count_curr == (M - 1)) ? 1'b1 : 1'b0;
    assign count_o = count_curr;

endmodule

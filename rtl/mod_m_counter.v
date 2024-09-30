// counter from 0 to M-1, then wraps around
module mod_m_counter
    #(
        parameter N = 4,  // number of bits in counter
        parameter M = 10  // number to count to
    )
    (
        input wire i_clk,        // clock
        input wire i_reset,      // reset
        output wire o_max_tick,  // max tick reached
        output wire [N-1:0] o_q  // counter value
    );
    
    // internal signals
    reg [N-1:0] r_reg;
    wire [N-1:0] r_next;

    // state
    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin
            r_reg <= 0;
        end
        else begin
            r_reg <= r_next;
        end
    end

    // next-state
    assign r_next = (r_reg == (M - 1)) ? 0 : r_reg + 1;

    // output
    assign o_q = r_reg;
    assign o_max_tick = (r_reg == (M - 1)) ? 1'b1 : 1'b0;

endmodule

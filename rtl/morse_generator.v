`include "./ascii_to_morse_code.v"

`timescale 1ns/1ps

module morse_generator
    #(
        parameter MORSE_CYCLES = 10 // morse base time unit
    )
    (
        input wire clk_i,         // clock
        input wire reset_i,       // reset
        input wire [7:0] ascii_i, // ASCII character
        input wire en_i,          // transmit signal enable
        output reg morse_o,       // morse code signal
        output wire done_o        // morse code signal done transmitting
    );

    // constants
    localparam DOT_CYCLES = 1 * MORSE_CYCLES;    // clock cycles for dot (1)
    localparam DASH_CYCLES = 3 * MORSE_CYCLES;   // clock cycles for dash (0)
    localparam SYMBOL_CYCLES = 1 * MORSE_CYCLES; // clock cycles for space between symbols in same letter
    localparam WORD_CYCLES = 7 * MORSE_CYCLES;   // clock cycles between words (detected by space)

    localparam COUNTER_BITS = $clog2(7 * MORSE_CYCLES) + 1;

    // state machine states
    localparam [2:0] STATE_IDLE   = 3'b000,
                     STATE_DOT    = 3'b001,
                     STATE_DASH   = 3'b010,
                     STATE_SYMBOL = 3'b011,
                     STATE_WORD   = 3'b100,
                     STATE_DONE   = 3'b101;

    // wiring/regs
    wire [3:0] morse_len;
    wire [5:0] morse_symbols;
    reg [2:0] state_curr, state_next;
    reg [2:0] symbol_curr, symbol_next;
    reg done_curr, done_next;
    reg [COUNTER_BITS-1:0] count_curr, count_next;

    // ASCII to morse symbols
    // A = .- => 6'bzzzz10 (len=2)
    ascii_to_morse_code ascii_to_morse (
        .ascii_i(ascii_i),
        .len_o(morse_len),
        .morse_o(morse_symbols)
    );

    // outputs
    assign done_o = done_curr;

    // register logic
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            state_curr <= STATE_IDLE;
            count_curr <= 0;
            symbol_curr <= 0;
            done_curr <= 1;
        end else begin
            state_curr <= state_next;
            count_curr <= count_next;
            symbol_curr <= symbol_next;
            done_curr <= done_next;
        end
    end

    // next state
    always @(*) begin
        // default behavior
        state_next = state_curr;
        count_next = count_curr;
        symbol_next = symbol_curr;
        done_next = done_curr;

        case (state_curr)

            // wait for start signal
            STATE_IDLE: begin
                symbol_next = 0;
                count_next = 0;
                done_next = 1'b0;
                morse_o = 1'b0;

                if (en_i) begin
                    if (ascii_i == 8'h20) begin
                        state_next = STATE_WORD;
                    end else if (morse_len > 0) begin
                        state_next = (morse_symbols[symbol_curr] == 1'b1) ? STATE_DOT : STATE_DASH;
                    end
                end
            end

            // generate morse dot
            STATE_DOT: begin
                morse_o = 1'b1;
                done_next = 1'b0;

                if (count_curr < DOT_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    state_next = STATE_SYMBOL;
                end
            end

            // generate morse dash
            STATE_DASH: begin
                morse_o = 1'b1;
                done_next = 1'b0;

                if (count_curr < DASH_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    state_next = STATE_SYMBOL;
                end
            end

            // wait between morse symbols
            STATE_SYMBOL: begin
                morse_o = 1'b0;
                done_next = 1'b0;

                if (count_curr < SYMBOL_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    symbol_next = symbol_curr + 1;

                    // check for next symbol in sequence
                    if ((symbol_curr + 1) < morse_len) begin
                        state_next = (morse_symbols[symbol_curr + 1] == 1'b1) ? STATE_DOT : STATE_DASH;
                    end else begin
                        state_next = STATE_DONE;
                    end
                end
            end

            // handle ASCII space as a break between words
            STATE_WORD: begin
                morse_o = 1'b0;
                symbol_next = 0;
                done_next = 1'b0;

                if (count_curr < WORD_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    state_next = STATE_DONE;
                end
            end

            // morse transmit is finished
            STATE_DONE: begin
                morse_o = 1'b0;
                symbol_next = 0;
                done_next = 1'b1;

                if (!en_i) begin
                    state_next = STATE_IDLE;
                end
            end

            // invalid state, go back to idle
            default: begin
                morse_o = 1'b0;
                symbol_next = 0;
                state_next = STATE_IDLE;
                done_next = 1'b0;
            end

        endcase
    end

endmodule

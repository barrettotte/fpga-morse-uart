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
        input wire start_i,       // begin transmitting signal

        output reg is_dot_o,
        output reg is_dash_o,
        output reg is_symbol_o,
        output reg is_word_o,

        output reg morse_o,       // morse code signal
        output reg done_o         // morse code signal done transmitting
    );

    // constants
    localparam DOT_CYCLES = 1 * MORSE_CYCLES;    // clock cycles for dot (1)
    localparam DASH_CYCLES = 3 * MORSE_CYCLES;   // clock cycles for dash (0)
    localparam SYMBOL_CYCLES = 1 * MORSE_CYCLES; // clock cycles for space between symbols in same letter
    localparam WORD_CYCLES = 7 * MORSE_CYCLES;   // clock cycles between words (detected by space)

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
    reg [2:0] symbol_index;
    reg [2:0] state_curr, state_next;
    reg [31:0] count_curr, count_next;

    // ASCII to morse symbols
    // A = .- => 6'bzzzz10 (len=2)
    ascii_to_morse_code ascii_to_morse (
        .ascii_i(ascii_i),
        .len_o(morse_len),
        .morse_o(morse_symbols)
    );

    // register logic
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            state_curr <= STATE_IDLE;
            count_curr <= 0;
            done_o <= 1'b1;
            morse_o <= 1'bz;
            symbol_index <= 0;
        end else begin
            state_curr <= state_next;
            count_curr <= count_next;
        end
    end

    // next state
    always @(*) begin
        // default behavior
        state_next = state_curr;
        count_next = count_curr;
        morse_o = 1'bz;
        done_o = 1'b0;

        is_dot_o = 1'b0;
        is_dash_o = 1'b0;
        is_symbol_o = 1'b0;
        is_word_o = 1'b0;

        case (state_curr)

            // wait for start signal
            STATE_IDLE: begin
                if (start_i) begin
                    symbol_index = 0;
                    count_next = 0;

                    if (ascii_i == 8'h20) begin
                        state_next = STATE_WORD;
                    end else if (morse_len > 0) begin
                        state_next = (morse_symbols[symbol_index] == 1'b1) ? STATE_DOT : STATE_DASH;
                    end else begin
                        state_next = STATE_DONE;
                    end
                end
            end

            // generate morse dot
            STATE_DOT: begin
                morse_o = 1'b1;
                is_dot_o = 1'b1;

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
                is_dash_o = 1'b1;

                if (count_curr < DASH_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    state_next = STATE_SYMBOL;
                end
            end

            // wait between morse symbols
            STATE_SYMBOL: begin
                is_symbol_o = 1'b1;

                if (count_curr < SYMBOL_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    symbol_index = symbol_index + 1;

                    // check for next symbol in sequence
                    if (symbol_index < morse_len) begin
                        state_next = (morse_symbols[symbol_index] == 1'b1) ? STATE_DOT : STATE_DASH;
                    end else begin
                        state_next = STATE_DONE;
                    end
                end
            end

            // handle ASCII space as a break between words
            STATE_WORD: begin
                symbol_index = 0;
                is_word_o = 1'b1;

                if (count_curr < WORD_CYCLES) begin
                    count_next = count_curr + 1;
                end else begin
                    count_next = 0;
                    state_next = STATE_DONE;
                end
            end

            // morse transmit is finished
            STATE_DONE: begin
                symbol_index = 0;
                done_o = 1'b1;

                if (!start_i) begin
                    state_next = STATE_IDLE;
                end
            end

        endcase
    end

endmodule

`timescale 1ns/1ps

// UART receiver (serial to parallel)
module uart_receiver
    #(
        parameter WORD_BITS = 8,    // bits in data word
        parameter SAMPLE_TICKS = 16 // stop bit/oversampling ticks 
                                    // 16/24/32 for 1/1.5/2 bits
    )
    (
        input wire clk_i,                  // clock
        input wire reset_i,                // reset
        input wire rx_i,                   // receive data bit
        input wire baud_i,                 // tick from baud generator
        output reg rx_done_o,              // signal when data receive is completed
        output wire [WORD_BITS-1:0] data_o // data to FIFO
    );

    // state machine states
    localparam [1:0] STATE_IDLE  = 2'b00,
                     STATE_START = 2'b01,
                     STATE_DATA  = 2'b10,
                     STATE_STOP  = 2'b11;

    // wiring/regs
    reg [1:0] state_curr, state_next;         // state
    reg [3:0] tick_curr, tick_next;           // number of ticks from baud generator
    reg [2:0] len_curr, len_next;             // number of bits received (2^3 = 8)
    reg [WORD_BITS-1:0] data_curr, data_next; // data word received

    // register logic
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            state_curr <= STATE_IDLE;
            tick_curr <= 0;
            len_curr <= 0;
            data_curr <= 0;
        end else begin
            state_curr <= state_next;
            tick_curr <= tick_next;
            len_curr <= len_next;
            data_curr <= data_next;
        end
    end

    // next state
    always @* begin
        state_next = state_curr;
        tick_next = tick_curr;
        len_next = len_curr;
        data_next = data_curr;
        rx_done_o = 1'b0;

        case (state_curr)
            STATE_IDLE: begin
                // rx high to low, start receiving
                if (~rx_i) begin
                    state_next = STATE_START;
                    tick_next = 0;
                end
            end

            STATE_START: begin
                if (baud_i) begin
                    // check middle of possible start bit to verify still low, otherwise back to IDLE
                    if (tick_curr == (SAMPLE_TICKS/2)-1) begin
                        state_next = STATE_DATA;
                        tick_next = 0;
                        len_next = 0;
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end

            STATE_DATA: begin
                if (baud_i) begin
                    // wait another bit width to sample
                    if (tick_curr == SAMPLE_TICKS-1) begin
                        tick_next = 0;

                        // shift in bits from LSB to MSB
                        data_next = {rx_i, data_curr[WORD_BITS-1:1]};

                        // check if done receiving bits
                        if (len_curr == WORD_BITS-1) begin
                            state_next = STATE_STOP;
                        end else begin
                            len_next = len_curr + 1;
                        end
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end

            STATE_STOP: begin
                if (baud_i) begin
                    if (tick_curr == SAMPLE_TICKS-1) begin
                        state_next = STATE_IDLE;
                        rx_done_o = 1'b1;
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end
        endcase
    end

    // output
    assign data_o = data_curr;

endmodule
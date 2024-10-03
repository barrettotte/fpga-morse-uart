`timescale 1ns/1ps

// UART transmitter (parallel to serial)
module uart_transmitter
    #(
        parameter WORD_BITS = 8,    // bits in data word
        parameter SAMPLE_TICKS = 16 // stop bit/oversampling ticks 
                                    // 16/24/32 for 1/1.5/2 bits
    )
    (
        input wire clk_i,                  // clock
        input wire reset_i,                // reset
        input wire tx_start_i,             // begin transmit
        input wire baud_i,                 // tick from baud generator
        input wire [WORD_BITS-1:0] data_i, // data from FIFO
        output reg tx_done_o,              // end of transmit
        output wire tx_o                   // bit to transmit
    );

    // state machine states
    localparam [1:0] STATE_IDLE  = 2'b00,
                     STATE_START = 2'b01,
                     STATE_DATA  = 2'b10,
                     STATE_STOP  = 2'b11;

    // internal
    reg [1:0] state_curr, state_next;         // state
    reg [3:0] tick_curr, tick_next;           // number of ticks from baud generator
    reg [2:0] nbits_curr, nbits_next;         // number of bits transmitted
    reg [WORD_BITS-1:0] data_curr, data_next; // data word to transmit serially
    reg tx_curr, tx_next;                     // bit to transmit (buffered)

    // register logic
    always @(posedge clk_i, posedge reset_i) begin
        if (reset_i) begin
            state_curr <= STATE_IDLE;
            tick_curr <= 0;
            nbits_curr <= 0;
            data_curr <= 0;
            tx_curr <= 0;
        end else begin
            state_curr <= state_next;
            tick_curr <= tick_next;
            nbits_curr <= nbits_next;
            data_curr <= data_next;
            tx_curr <= tx_next;
        end
    end

    // next state
    always @* begin
        state_next = state_curr;
        tick_next = tick_curr;
        nbits_next = nbits_curr;
        data_next = data_curr;
        tx_next = tx_curr;
        tx_done_o = 1'b0;

        case (state_curr)
            STATE_IDLE: begin
                tx_next = 1'b1;

                if (tx_start_i) begin
                    state_next = STATE_START;
                    tick_next = 0;
                    data_next = data_i;
                end
            end

            STATE_START: begin
                tx_next = 1'b0; // start bit (active low)

                if (baud_i) begin
                    if (tick_curr == SAMPLE_TICKS-1) begin
                        state_next = STATE_DATA;
                        tick_next = 0;
                        nbits_next = 0;
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end

            STATE_DATA: begin
                tx_next = data_curr[0];

                if (baud_i) begin
                    if (tick_curr == SAMPLE_TICKS-1) begin
                        tick_next = 0;
                        data_next = data_curr >> 1;

                        // check if done transmitting bits
                        if (nbits_curr == WORD_BITS-1) begin
                            state_next = STATE_STOP;
                        end else begin
                            nbits_next = nbits_curr + 1;
                        end
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end

            STATE_STOP: begin
                tx_next = 1'b1; // go back to idling

                if (baud_i) begin
                    if (tick_curr == SAMPLE_TICKS-1) begin
                        state_next = STATE_IDLE;
                        tx_done_o = 1'b1;
                    end else begin
                        tick_next = tick_curr + 1;
                    end
                end
            end
        endcase
    end

    // output
    assign tx_o = tx_curr;

endmodule

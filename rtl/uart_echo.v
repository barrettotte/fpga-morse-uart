`include "./baud_generator.v"
`include "./fifo.v"
`include "./uart_receiver.v"
`include "./uart_transmitter.v"

`timescale 1ns/1ps

module uart_echo
    #(
        parameter WORD_BITS = 8,     // bits in data word

        parameter SAMPLE_TICKS = 16, // stop bit/oversampling ticks
                                     // 16/24/32 for 1/1.5/2 bits

        parameter BAUD_LIMIT = 651,  // baud rate counter limit
                                     // (clock rate) / (baud rate * oversamples)
                                     // (100 * 10^6) / (9600(16)) = ~651

        parameter BAUD_BITS = 10,    // bits needed for BAUD_LIMIT
                                     // log2(BAUD_LIMIT) = log2(651) = ~10

        parameter FIFO_ADDR_BITS = 4 // FIFO addresses
                                     // 2^4 = 16 words
    )
    (
        input wire clk_i,                      // clock
        input wire reset_i,                    // reset
        input wire rx_i,                       // serial data in
        output wire tx_o,                      // serial data out

        output wire [WORD_BITS-1:0] tx_data_o, // data from tx fifo to transmit
        output wire [WORD_BITS-1:0] rx_data_o, // data from received from uart
        output wire baud_tick_o,               // baud signal

        output wire fifo_empty_o,              // fifo is empty, no reads
        output wire fifo_full_o,               // fifo is full, no writes

        output wire tx_done_o,                 // done transmitting word
        output wire rx_done_o                  // done receiving word
    );

    // wiring/regs
    wire [WORD_BITS-1:0] rx_to_fifo;
    wire [WORD_BITS-1:0] fifo_to_tx;
    wire fifo_write, fifo_read;

    // baud rate generator
    baud_generator #(.M(BAUD_LIMIT), .N(BAUD_BITS)) baud (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .tick_o(baud_tick_o),
        .count_o() // disconnected, not needed
    );

    uart_receiver #(.WORD_BITS(WORD_BITS), .SAMPLE_TICKS(SAMPLE_TICKS)) uart_rx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .rx_i(rx_i),
        .baud_i(baud_tick_o),
        .rx_done_o(rx_done_o),
        .data_o(rx_to_fifo)
    );

    fifo #(.WORD_BITS(WORD_BITS), .ADDR_BITS(FIFO_ADDR_BITS)) fifo_rx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .read_i(fifo_read),
        .write_i(fifo_write),
        .wdata_i(rx_to_fifo),
        .rdata_o(fifo_to_tx),
        .empty_o(fifo_empty_o),
        .full_o(fifo_full_o)
    );

    uart_transmitter #(.WORD_BITS(WORD_BITS), .SAMPLE_TICKS(SAMPLE_TICKS)) uart_tx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .tx_start_i(tx_start),
        .baud_i(baud_tick_o),
        .data_i(fifo_to_tx),
        .tx_done_o(tx_done_o),
        .tx_o(tx_o)
    );

    reg tx_start;
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            tx_start <= 0;
        end else if (rx_done_o && !fifo_full_o) begin
            tx_start <= 1; // Start transmission when a byte is received
        end else if (tx_done_o) begin
            tx_start <= 0; // Reset tx_start after transmission is complete
        end
    end

    assign rx_data_o = rx_to_fifo;
    assign tx_data_o = fifo_to_tx;

    assign fifo_write = rx_done_o && !fifo_full_o;
    assign fifo_read = tx_done_o && !fifo_empty_o;

endmodule

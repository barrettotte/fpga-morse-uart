`include "./baud_generator.v"
`include "./fifo.v"
`include "./uart_receiver.v"
`include "./uart_transmitter.v"

`timescale 1ns/1ps

module uart_top
    #(
        parameter WORD_BITS = 8,     // bits in data word

        parameter SAMPLE_TICKS = 16, // stop bit/oversampling ticks
                                     // 16/24/32 for 1/1.5/2 bits

        parameter BAUD_LIMIT = 651,  // baud rate counter limit
                                     // (clock rate) / (baud rate * oversamples)
                                     // (100 * 10^6) / (9600(16)) = ~651

        parameter BAUD_BITS = 10,    // bits needed for BAUD_LIMIT
                                     // log2(BAUD_LIMIT) = log2(651) = ~10

        parameter FIFO_ADDR_BITS = 2 // FIFO addresses
                                     // 2^2 = 4 words
    )
    (
        // inputs
        input wire clk_i,                            // clock
        input wire reset_i,                          // reset
        input wire rx_i,                             // serial data in

        // outputs
        output wire tx_o,                            // serial data out

        output wire baud_tick_o,                     // baud signal
        output wire tx_done_o,                       // done transmitting word
        output wire rx_done_o                        // done receiving word
    );

    // internals
    wire [WORD_BITS-1:0] rx_data;
    wire rx_fifo_empty;
    wire rx_fifo_full;

    reg tx_fifo_read;
    wire tx_fifo_empty;
    wire tx_fifo_full;
    wire [WORD_BITS-1:0] tx_data;
    
    // baud rate generator
    baud_generator #(.M(BAUD_LIMIT), .N(BAUD_BITS)) baud (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .tick_o(baud_tick_o),
        .count_o() // disconnected, not needed
    );

    // UART receiver
    uart_receiver #(.WORD_BITS(WORD_BITS), .SAMPLE_TICKS(SAMPLE_TICKS)) uart_rx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .rx_i(rx_i),
        .baud_i(baud_tick_o),
        .rx_done_o(rx_done_o),
        .data_o(rx_data)
    );
    fifo #(.WORD_BITS(WORD_BITS), .ADDR_BITS(FIFO_ADDR_BITS)) fifo_rx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .read_i(1'b0),
        .write_i(rx_done_o),
        .wdata_i(rx_data),
        .rdata_o(),
        .empty_o(rx_fifo_empty),
        .full_o(rx_fifo_full)
    );

    // UART transmitter
    uart_transmitter #(.WORD_BITS(WORD_BITS), .SAMPLE_TICKS(SAMPLE_TICKS)) uart_tx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .tx_start_i(~tx_fifo_empty), // transmit when data available
        .baud_i(baud_tick_o),
        .data_i(tx_data),            // data from tx FIFO
        .tx_done_o(tx_done_o),
        .tx_o(tx_o)
    );
    fifo #(.WORD_BITS(WORD_BITS), .ADDR_BITS(FIFO_ADDR_BITS)) fifo_tx (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .read_i(tx_fifo_read),
        .write_i(~rx_fifo_empty),
        .wdata_i(rx_data),
        .rdata_o(tx_data),
        .empty_o(tx_fifo_empty),
        .full_o(tx_fifo_full)
    );

    // register logic
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            tx_fifo_read <= 1'b0;
        end else begin
            // read from tx FIFO if not empty and tx is done
            if (~tx_fifo_empty && tx_done_o) begin
                tx_fifo_read <= 1'b1;
            end else begin
                tx_fifo_read <= 1'b0;
            end
        end
    end


endmodule

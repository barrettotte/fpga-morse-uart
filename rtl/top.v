`include "./seven_seg_controller.v"
`include "./uart_echo.v"
`include "./morse_generator.v"

`timescale 1ns/1ps

module top
    (
        input wire clk_i,                    // clock (100MHz)
        input wire reset_i,                  // reset
        input wire rx_i,                     // bit received over UART
        output wire tx_o,                    // bit transmitted over UART
        output wire [6:0] sev_seg_encoded_o, // 7-segment encoded value
        output wire [3:0] sev_seg_anodes_o,  // 7-segment selector
        output wire morse_o                  // morse signal
    );

    // constants
    localparam CLK_FREQ = 100 * (10**6);
    localparam WORD_BITS = 8;
    localparam SAMPLE_TICKS = 16;
    localparam BAUD_RATE = 9600;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE / SAMPLE_TICKS;
    localparam BAUD_BITS = $clog2(BAUD_DIV);
    localparam UART_FIFO_ADDR_BITS = 3; // 8 bytes
    localparam SEV_SEG_REFRESH = 1000;
    localparam MORSE_CYCLES = 20_000_000; // 10 * (10**6); // 200ms

    // wiring/regs
    wire [WORD_BITS-1:0] rx_data; // data from UART receiver to FIFO
    wire [WORD_BITS-1:0] tx_data; // data from FIFO to UART transmitter
    wire rx_done, tx_done;
    wire uart_fifo_empty, uart_fifo_full;

    // UART echo
    uart_echo #(
        .WORD_BITS(WORD_BITS),
        .SAMPLE_TICKS(SAMPLE_TICKS),
        .BAUD_LIMIT(BAUD_DIV),
        .BAUD_BITS(BAUD_BITS),
        .FIFO_ADDR_BITS(UART_FIFO_ADDR_BITS)
    ) uart (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .rx_i(rx_i),
        .tx_o(tx_o),
        .tx_data_o(tx_data),
        .rx_data_o(rx_data),
        .rx_done_o(rx_done),
        .tx_done_o(tx_done),
        .fifo_empty_o(uart_fifo_empty),
        .fifo_full_o(uart_fifo_full),
        // disconnected
        .baud_tick_o()
    );

    // 7-segment display controller
    seven_seg_controller #(
        .REFRESH_FREQ(SEV_SEG_REFRESH),
        .CLK_FREQ(CLK_FREQ)
    ) display (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .data_i({8'b0, rx_data}),
        .segs_o(sev_seg_encoded_o),
        .anodes_o(sev_seg_anodes_o)
    );

    // ASCII to morse code generator
    morse_generator #(
        .MORSE_CYCLES(MORSE_CYCLES)
    ) morse (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .ascii_i(rx_data),
        .en_i(rx_done),
        .morse_o(morse_o),
        // disconnected
        .done_o()
    );

endmodule

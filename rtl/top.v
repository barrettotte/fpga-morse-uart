`include "./seven_seg_controller.v"
`include "./uart_echo.v"

`timescale 1ns/1ps

module top
    (
        input wire clk_i,                    // clock (100MHz)
        input wire reset_i,                  // reset

        input wire rx_i,                     // bit received over UART
        output wire tx_o,                    // bit transmitted over UART

        output wire rx_done_o,               // UART receive finished
        output wire tx_done_o,               // UART transmit finished
        output wire fifo_empty_o,            // FIFO empty, no reads
        output wire fifo_full_o,             // FIFO full, no write

        output wire [6:0] sev_seg_encoded_o, // 7-segment encoded value
        output wire [3:0] sev_seg_anodes_o,  // 7-segment selector

        // temp
        output wire [7:0] tx_data_o
    );

    // constants
    localparam CLK_FREQ = 100 * (10**6);
    localparam WORD_BITS = 8;
    localparam SAMPLE_TICKS = 16;
    localparam BAUD_RATE = 9600;
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE / SAMPLE_TICKS;
    localparam BAUD_BITS = $clog2(BAUD_DIV);
    localparam FIFO_ADDR_BITS = 5; // 32 bytes
    localparam SEV_SEG_REFRESH = 1000;

    // wiring/regs
    wire [WORD_BITS-1:0] rx_data;
    wire [WORD_BITS-1:0] tx_data;

    // UART echo
    uart_echo #(
        .WORD_BITS(WORD_BITS),
        .SAMPLE_TICKS(SAMPLE_TICKS),
        .BAUD_LIMIT(BAUD_DIV),
        .BAUD_BITS(BAUD_BITS),
        .FIFO_ADDR_BITS(FIFO_ADDR_BITS)
    ) uart (
        .clk_i(clk_i),
        .reset_i(reset_i),
        .rx_i(rx_i),
        .tx_o(tx_o),
        .tx_data_o(tx_data),
        .rx_data_o(rx_data),
        .rx_done_o(rx_done_o),
        .tx_done_o(tx_done_o),
        .fifo_empty_o(fifo_empty_o),
        .fifo_full_o(fifo_full_o),

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

    assign tx_data_o = tx_data;

endmodule

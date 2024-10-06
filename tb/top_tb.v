`include "include/assert.vh"
`include "../rtl/top.v"

`timescale 1ns/1ps

module top_tb;

    // constants
    localparam WORD_BITS = 8;
    localparam SAMPLE_TICKS = 16;

    // clock frequency in megahertz
    localparam CLK_FREQ = 100 * (10**6); // 100MHz

    // clock period
    // T = (1 / f) * (10^7)
    // Example: (1 / (100 * (10^6))) * (10^9) = 10ns
    localparam CLK_PERIOD = (10**9 / (CLK_FREQ));

    // standard values: 9600, 19200, 38400, 57600, 115200
    localparam BAUD_RATE = 9600;

    // Clock cycles per bit.
    // cycles = (f * T) / baud rate
    // Example: 1/9600 = 104.167us = ~104167ns
    localparam real CYCLES_PER_BIT = (CLK_FREQ * CLK_PERIOD) / BAUD_RATE;

    // inputs
    reg clk = 0;
    reg reset = 0;
    reg rx = 0;

    // outputs
    wire tx;
    wire rx_done;
    wire tx_done;
    wire uart_fifo_empty;
    wire uart_fifo_full;
    wire [6:0] sev_seg_encoded;
    wire [3:0] sev_seg_anodes;
    wire morse;

    // design under test
    top DUT (
        .clk_i(clk),
        .reset_i(reset),
        .rx_i(rx),
        .tx_o(tx),
        .rx_done_o(rx_done),
        .tx_done_o(tx_done),
        .uart_fifo_empty_o(uart_fifo_empty),
        .uart_fifo_full_o(uart_fifo_full),
        .sev_seg_encoded_o(sev_seg_encoded),
        .sev_seg_anodes_o(sev_seg_anodes),
        .morse_o(morse)
    );

    // test
    integer bit_idx = WORD_BITS+1;
    reg [2+(WORD_BITS-1):0] transmitted;

    // clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);

        // init
        clk = 0;
        reset = 1;
        rx = 1; // idle

        // reset
        #(5 * CLK_PERIOD);
        reset = 0;

        // send byte and wait for done signal
        uart_send_packet(8'b11001100);
        wait (rx_done);

        // receive transmitted bits
        bit_idx = WORD_BITS+1;
        repeat (WORD_BITS+1) begin
            #(CYCLES_PER_BIT);
            transmitted[bit_idx] = tx;
            bit_idx = bit_idx - 1;
        end
        #(CYCLES_PER_BIT);
        transmitted[bit_idx] = tx;

        // wait for transmit complete
        wait (tx_done);
        `ASSERT_W_MSG({1'b0, 8'b00110011, 1'b1}, transmitted, "asserting transmitted bits")
        // start bit, data (LSB to MSB), stop bit

        // wait a couple extra baud intervals
        #(3 * CYCLES_PER_BIT)
        
        // done
        #(10 * CLK_PERIOD);
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

    // transmit UART packet to receiver rx line
    task uart_send_packet(input [WORD_BITS-1:0] data);
        integer i;
        begin
            // start bit
            #(CYCLES_PER_BIT);
            rx = 0;

            // data bits (LSB first)
            for (i = 0; i < WORD_BITS; i = i + 1) begin
                $display("Sending bit %0d = %0d", i, data[i]);
                #(CYCLES_PER_BIT);
                rx = data[i];
            end

            // stop bit
            #(CYCLES_PER_BIT);
            rx = 1;
        end
    endtask

endmodule

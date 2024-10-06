`include "include/assert.vh"
`include "../rtl/uart_receiver.v"
`include "../rtl/baud_generator.v"

`timescale 1ns/1ps

module uart_receiver_tb;

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

    // clock divider for baud rate.
    // baud divider = (f / baud rate) / samples
    // Example: 100,000,000 / 9600 / 16 = ~651
    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE / SAMPLE_TICKS;

    // Clock cycles per bit.
    // cycles = (f * T) / baud rate
    // Example: 1/9600 = 104.167us = ~104167ns
    localparam real CYCLES_PER_BIT = (CLK_FREQ * CLK_PERIOD) / BAUD_RATE;

    // inputs
    reg clk = 0;
    reg reset = 0;
    reg rx = 0;

    // outputs
    wire rx_done;
    wire [WORD_BITS-1:0] data;
    wire baud_tick;

    // baud rate generator. N = log2(651) = ~10 bits, M = clock divider
    baud_generator #(.N($clog2(BAUD_DIV)), .M(BAUD_DIV)) baud_gen (
        .clk_i(clk),
        .reset_i(reset),
        .tick_o(baud_tick),
        .count_o()
    );

    // design under test
    uart_receiver #(
        .WORD_BITS(WORD_BITS),
        .SAMPLE_TICKS(SAMPLE_TICKS)
    ) 
    DUT (
        .clk_i(clk),
        .reset_i(reset),
        .rx_i(rx),
        .baud_i(baud_tick),
        .rx_done_o(rx_done),
        .data_o(data)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("uart_receiver_tb.vcd");
        $dumpvars(0, uart_receiver_tb);
        $monitor("At time %t: baud_tick=%0d, data=%0d, rx_done=%0d", $time, baud_tick, data, rx_done);

        // init
        clk = 0;
        reset = 1;
        rx = 1; // idle

        // reset
        #(2 * CLK_PERIOD);
        reset = 0;

        // wait for stability
        #(4 * CLK_PERIOD);

        // send byte and wait for done signal
        uart_send_packet(8'b01010101);
        wait (rx_done);

        // check data received successfully
        `ASSERT(8'b01010101, data)

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

`include "include/assert.vh"
`include "../rtl/uart_transmitter.v"
`include "../rtl/baud_generator.v"

`timescale 1ns/1ps

module uart_transmitter_tb;

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
    reg tx_start = 0;
    reg [WORD_BITS-1:0] data;

    // outputs
    wire tx_done;
    wire tx;

    // baud rate generator. N = log2(651) = ~10 bits, M = clock divider
    baud_generator #(.N($clog2(BAUD_DIV)), .M(BAUD_DIV)) baud_gen (
        .clk_i(clk),
        .reset_i(reset),
        .tick_o(baud_tick),
        .count_o()
    );

    // design under test
    uart_transmitter #(
        .WORD_BITS(WORD_BITS),
        .SAMPLE_TICKS(SAMPLE_TICKS)
    )
    DUT(
        .clk_i(clk),
        .reset_i(reset),
        .tx_start_i(tx_start),
        .baud_i(baud_tick),
        .data_i(data),
        .tx_done_o(tx_done),
        .tx_o(tx)
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
        $dumpfile("uart_transmitter_tb.vcd");
        $dumpvars(0, uart_transmitter_tb);
        $monitor("At time %t: tx=%0b, done=%0b, transmitted=%0b", $time, tx, tx_done, transmitted);

        // init
        clk = 0;
        reset = 1;
        tx_start = 0;

        // reset
        #(2 * CLK_PERIOD);
        reset = 0;

        // wait for stability
        #(4 * CLK_PERIOD);

        // start transmission
        data = 8'b01010101;
        transmitted = 10'bx;
        tx_start = 1;
        #(10 * CLK_PERIOD);
        tx_start = 0;

        // start bit
        `ASSERT_W_MSG(1'b0, tx, "asserting start bit.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 0
        `ASSERT_W_MSG(1'b1, tx, "asserting bit 0.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 1
        `ASSERT_W_MSG(1'b0, tx, "asserting bit 1.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 2
        `ASSERT_W_MSG(1'b1, tx, "asserting bit 2.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 3
        `ASSERT_W_MSG(1'b0, tx, "asserting bit 3.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 4
        `ASSERT_W_MSG(1'b1, tx, "asserting bit 4.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 5
        `ASSERT_W_MSG(1'b0, tx, "asserting bit 5.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 6
        `ASSERT_W_MSG(1'b1, tx, "asserting bit 6.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // bit 7
        `ASSERT_W_MSG(1'b0, tx, "asserting bit 7.");
        transmitted[bit_idx] = tx;
        bit_idx = bit_idx - 1;
        #(CYCLES_PER_BIT);

        // stop bit
        `ASSERT_W_MSG(1'b1, tx, "asserting stop bit.");
        transmitted[bit_idx] = tx;

        // wait for transmit complete
        wait(tx_done);
        `ASSERT_W_MSG({1'b0, 8'b10101010, 1'b1}, transmitted, "asserting transmitted bits");
        // start bit, data (LSB to MSB), stop bit

        // reinit for another byte
        #25000;
        clk = 0;
        reset = 1;
        tx_start = 0;

        // reset
        #(2 * CLK_PERIOD);
        reset = 0;

        // wait for stability
        #(4 * CLK_PERIOD);

        // start transmission
        data = 8'b11001100;
        transmitted = 10'bx;
        tx_start = 1;
        #(10 * CLK_PERIOD);
        tx_start = 0;

        // receive transmitted bits
        bit_idx = WORD_BITS+1;
        repeat(WORD_BITS+1) begin
            transmitted[bit_idx] = tx;
            bit_idx = bit_idx - 1;
            #(CYCLES_PER_BIT);
        end
        transmitted[bit_idx] = tx;

        // wait for transmit complete
        wait(tx_done);
        `ASSERT_W_MSG({1'b0, 8'b00110011, 1'b1}, transmitted, "asserting transmitted bits");
        // start bit, data (LSB to MSB), stop bit
        
        // done
        #(10 * CLK_PERIOD);
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

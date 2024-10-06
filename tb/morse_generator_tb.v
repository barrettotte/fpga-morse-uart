`include "include/assert.vh"
`include "../rtl/morse_generator.v"

`timescale 1ns/1ps

module morse_generator_tb;

    // clock frequency in megahertz
    localparam CLK_FREQ = 100 * (10**6); // 100MHz

    // clock period
    // T = (1 / f) * (10^7)
    // Example: (1 / (100 * (10^6))) * (10^9) = 10ns
    localparam CLK_PERIOD = (10**9 / (CLK_FREQ));

    // cycles for each morse unit
    localparam MORSE_CYCLES = 2;

    // inputs
    reg clk = 0;
    reg reset = 0;
    reg [7:0] ascii = 0;
    reg start = 0;

    // outputs
    wire morse;
    wire done;

    wire is_dash;
    wire is_dot;
    wire is_symbol;
    wire is_word;

    // design under test
    morse_generator #(
        .MORSE_CYCLES(MORSE_CYCLES)
    )
    DUT (
        .clk_i(clk),
        .reset_i(reset),
        .ascii_i(ascii),
        .start_i(start),
        .morse_o(morse),
        .done_o(done),

        .is_dash_o(is_dash),
        .is_dot_o(is_dot),
        .is_symbol_o(is_symbol),
        .is_word_o(is_word)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("morse_generator_tb.vcd");
        $dumpvars(0, morse_generator_tb);
        // $monitor("At time %t: tx=%0b, done=%0b, transmitted=%0b", $time, tx, tx_done, transmitted);

        // init
        clk = 0;
        reset = 1;

        // reset
        #(2 * CLK_PERIOD);
        reset = 0;

        // wait for stability
        #(4 * CLK_PERIOD);

        // test morse conversion
        ascii = 8'h41; // 'A' (01000001)
        start = 1;
        #(CLK_PERIOD);

        // wait for dot
        #(1 * MORSE_CYCLES);
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 1 of 'A', dot")

        #(3 * MORSE_CYCLES);
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 2 of 'A', dash")
        
        wait (done);
        
        // done
        #(10 * CLK_PERIOD);
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

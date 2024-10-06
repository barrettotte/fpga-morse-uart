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
    reg en = 0;

    // outputs
    wire morse;
    wire done;

    // design under test
    morse_generator #(
        .MORSE_CYCLES(MORSE_CYCLES)
    )
    DUT (
        .clk_i(clk),
        .reset_i(reset),
        .ascii_i(ascii),
        .en_i(en),
        .morse_o(morse),
        .done_o(done)
    );

    integer i;

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
        ascii = 8'h41; // 'A' (01000001) => '.-'
        en = 1;
        #(CLK_PERIOD);

        #(1 * MORSE_CYCLES); // dot
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 1 of 'A', dot")
        #(1 * MORSE_CYCLES); // between

        #(3 * MORSE_CYCLES); // dash
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 2 of 'A', dash")
        #(1 * MORSE_CYCLES); // between

        wait (done);
        #(CLK_PERIOD);

        // test another character
        ascii = 8'b00111001; // '9' => '----.'
        en = 1;
        #(CLK_PERIOD);

        #(3 * MORSE_CYCLES); // dash
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 1 of '9', dash")
        #(1 * MORSE_CYCLES); // between

        #(3 * MORSE_CYCLES); // dash
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 2 of '9', dash")
        #(1 * MORSE_CYCLES); // between

        #(3 * MORSE_CYCLES); // dash
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 3 of '9', dash")
        #(1 * MORSE_CYCLES); // between

        #(3 * MORSE_CYCLES); // dash
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 4 of '9', dash")
        #(1 * MORSE_CYCLES); // between

        #(1 * MORSE_CYCLES); // dot
        `ASSERT_W_MSG(1'b1, morse, "Asserting symbol 5 of '9', dot")
        #(1 * MORSE_CYCLES); // between

        wait (done);
        
        // done
        #(10 * CLK_PERIOD);
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

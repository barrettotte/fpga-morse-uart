`include "include/assert.vh"
`include "../rtl/seven_seg_controller.v"

`timescale 1ns/1ps

module seven_seg_controller_tb;

    // clock frequency in megahertz
    localparam CLK_FREQ = 100 * (10**6); // 100MHz

    // clock period
    // T = (1 / f) * (10^7)
    // Example: (1 / (100 * (10^6))) * (10^9) = 10ns
    localparam CLK_PERIOD = (10**9 / (CLK_FREQ));

    // refresh rate
    localparam REFRESH_FREQ = 1000;

    // clock cycles per digit refresh
    localparam CYCLES_PER_DIGIT = CLK_PERIOD * ((CLK_FREQ / REFRESH_FREQ) / 4);

    // inputs
    reg clk = 0;
    reg reset = 0;
    reg [15:0] data = 0;

    // outputs
    wire [6:0] segs;
    wire [3:0] anodes;

    // design under test
    seven_seg_controller #(
        .CLK_FREQ(CLK_FREQ),
        .REFRESH_FREQ(REFRESH_FREQ)
    ) DUT (
        .clk_i(clk),
        .reset_i(reset),
        .data_i(data),
        .segs_o(segs),
        .anodes_o(anodes)
    );

    // clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        $dumpfile("seven_seg_controller_tb.vcd");
        $dumpvars(0, seven_seg_controller_tb);
        $monitor("At time %t: anodes=%b, segs=%b", $time, anodes, segs);

        // init
        clk = 0;
        reset = 1;
        data = 0;

        // reset
        #(5 * CLK_PERIOD);
        reset = 0;

        // assert default state
        `ASSERT_W_MSG(4'b1111, anodes, "Asserting all digits inactive")
        `ASSERT_W_MSG(7'b1111111, segs, "Asserting all segments inactive")

        // set test data
        data = 16'b1010_1011_1100_1101; // ABCD

        // digit 1 - 'D'
        #(CYCLES_PER_DIGIT);
        `ASSERT_W_MSG(4'b1110, anodes, "Asserting digit 1 active")
        `ASSERT_W_MSG(7'b0100001, segs, "Asserting 'D' in digit 1")
        
        // digit 2 - 'C'
        #(CYCLES_PER_DIGIT);
        `ASSERT_W_MSG(4'b1101, anodes, "Asserting digit 2 active")
        `ASSERT_W_MSG(7'b1000110, segs, "Asserting 'C' in digit 2")

        // digit 3 - 'B'
        #(CYCLES_PER_DIGIT);
        `ASSERT_W_MSG(4'b1011, anodes, "Asserting digit 3 active")
        `ASSERT_W_MSG(7'b0000011, segs, "Asserting 'B' in digit 3")

        // digit 4 - 'A'
        #(CYCLES_PER_DIGIT);
        `ASSERT_W_MSG(4'b0111, anodes, "Asserting digit 4 active")
        `ASSERT_W_MSG(7'b0001000, segs, "Asserting 'A' in digit 4")
        
        // done
        #(10 * CLK_PERIOD);
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

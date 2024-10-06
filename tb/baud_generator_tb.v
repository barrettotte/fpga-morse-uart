`include "include/assert.vh"
`include "../rtl/baud_generator.v"
`timescale 1ns/1ps

module baud_generator_tb;
    localparam N = 10;  // counter bits
    localparam M = 651; // count to

    // inputs
    reg clk = 0;
    reg reset = 0;

    // outputs
    wire tick;
    wire [N-1:0] count;

    // design under test
    baud_generator #(
        .N(N), 
        .M(M)
    ) DUT (
        .clk_i(clk),
        .reset_i(reset),
        .tick_o(tick),
        .count_o(count)
    );

    // track test number
    integer test_idx = 1;

    // generate 100MHz clock signal (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("baud_generator_tb.vcd");
        $dumpvars(0, baud_generator_tb);
        $monitor("At time %t: tick=%0d", $time, tick);

        // init
        clk = 0;
        reset = 0;

        // reset
        reset = 1;
        #10;
        reset = 0;

        // check counter max
        $display("test %0d", test_idx);
        repeat(M) @(posedge clk);
        `ASSERT(1, tick)
        test_idx = test_idx + 1;

        // check counter reset correctly
        $display("test %0d", test_idx);
        repeat(3) @(posedge clk);
        `ASSERT(0, tick)
        `ASSERT(2, count)
        test_idx = test_idx + 1;

        // done
        #20;
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

`include "include/assert.vh"
`include "../rtl/mod_m_counter.v"
`timescale 1ns/1ps

module mod_m_counter_tb;
    localparam N = 4;  // number of bits
    localparam M = 10; // number to count to

    // inputs
    reg clk_100M = 0;
    reg reset = 0;

    // outputs
    wire max_tick;
    wire [N-1:0] q;

    // design under test
    mod_m_counter #(.N(N), .M(M)) DUT (
        .i_clk(clk_100M),
        .i_reset(reset),
        .o_max_tick(max_tick),
        .o_q(q)
    );

    // track test number
    integer test_idx = 1;

    // generate 100MHz clock signal (10ns period)
    always #5 clk_100M = ~clk_100M;

    initial begin
        $dumpfile("mod_m_counter_tb.vcd");
        $dumpvars(0, mod_m_counter_tb);
        $monitor("At time %t: q=%0d, max_tick=%0d", $time, q, max_tick);

        // init
        clk_100M = 0;
        reset = 0;

        // reset
        reset = 1;
        #10;
        reset = 0;
        
        // check counter max
        $display("test %0d", test_idx);
        repeat(M) @(posedge clk_100M);
        
        `assert(1, max_tick);
        `assert(M-1, q);
        test_idx = test_idx + 1;

        // check counter reset correctly
        $display("test %0d", test_idx);
        repeat(3) @(posedge clk_100M);
        
        `assert(0, max_tick);
        `assert(2, q);
        test_idx = test_idx + 1;

        // done
        #20;
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

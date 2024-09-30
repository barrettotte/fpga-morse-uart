`include "include/assert.vh"
`include "../rtl/fifo.v"
`timescale 1ns/1ps

module fifo_tb;
    localparam WORD_BITS = 8;
    localparam ADDR_BITS = 4;

    // inputs
    reg clk_100M = 0;
    reg reset = 0;
    reg rd = 0;
    reg wr = 0;
    reg [WORD_BITS-1:0] wdata;

    // outputs
    wire empty;
    wire full;
    wire [WORD_BITS-1:0] rdata;

    // design under test
    fifo #(
        .WORD_BITS(WORD_BITS),
        .ADDR_BITS(ADDR_BITS)
    ) 
    DUT(
        .i_clk(clk_100M),
        .i_reset(reset),
        .i_rd(rd),
        .i_wr(wr),
        .i_wdata(wdata),
        .o_empty(empty),
        .o_full(full),
        .o_rdata(rdata)
    );

    // generate 100MHz clock signal (10ns period)
    always #5 clk_100M = ~clk_100M;

    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        // init
        clk_100M = 0;
        reset = 0;
        wr = 0;
        rd = 0;
        wdata = 0;

        // reset
        #10 reset = 1;
        @(posedge clk_100M);
        #10 reset = 0;
        @(posedge clk_100M);
        `assert(full, 0);
        `assert(empty, 1);
        
        // write until buffer is full
        $display("Writing to buffer:");
        repeat((2**ADDR_BITS)+1) begin
            @(posedge clk_100M);
            wr = 1;
            #1 $display("Wrote %0d to buffer, full=%0d, empty=%0d", wdata, full, empty);
            wdata = wdata + 1;
        end
        wr = 0;

        // assert state
        `assert(empty, 0);
        `assert(full, 1);

        // try writing to full buffer
        @(posedge clk_100M);
        wr = 1;
        wdata = wdata + 1;
        #1 $display("Attempted to write %0d to full buffer, full=%0d", wdata, full);
        wr = 0;

        // read from buffer until empty
        $display("Reading from buffer:");
        repeat((2**ADDR_BITS)+1) begin
            @(posedge clk_100M);
            rd = 1;
            #1 $display("Read %0d from buffer, full=%0d, empty=%0d", rdata, full, empty);
        end
        rd = 0;

        // assert state
        `assert(full, 0);
        `assert(empty, 1);

        // try reading from empty buffer
        @(posedge clk_100M);
        rd = 1;
        #1 $display("Attempted to read from empty buffer, rdata=%0d, empty=%0d", rdata, empty);
        rd = 0;

        #20;
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

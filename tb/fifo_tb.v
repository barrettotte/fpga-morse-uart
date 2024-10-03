`include "include/assert.vh"
`include "../rtl/fifo.v"
`timescale 1ns/1ps

module fifo_tb;
    // constants
    localparam WORD_BITS = 8;
    localparam ADDR_BITS = 4;

    // inputs
    reg clk = 0;
    reg reset = 0;
    reg read = 0;
    reg write = 0;
    reg [WORD_BITS-1:0] wdata;

    // outputs
    wire empty;
    wire full;
    wire [WORD_BITS-1:0] rdata;

    // design under test
    fifo #(.WORD_BITS(WORD_BITS), .ADDR_BITS(ADDR_BITS)) DUT(
        .clk_i(clk),
        .reset_i(reset),
        .read_i(read),
        .write_i(write),
        .wdata_i(wdata),
        .empty_o(empty),
        .full_o(full),
        .rdata_o(rdata)
    );

    // generate 100MHz clock signal (10ns period)
    always #5 clk = ~clk;

    initial begin
        $dumpfile("fifo_tb.vcd");
        $dumpvars(0, fifo_tb);

        // init
        clk = 0;
        reset = 0;
        write = 0;
        read = 0;
        wdata = 0;

        // reset
        #20 reset = 1;
        #20 reset = 0;
        `ASSERT(full, 0);
        `ASSERT(empty, 1);

        #100; // wait for stability
        
        // write until buffer is full
        $display("Writing to buffer:");
        repeat((2**ADDR_BITS)) begin
            // start write
            write = 1;
            wdata = wdata + 1;
            @(posedge clk);

            // done write
            write = 0;
            #1 $display("Wrote %0d to buffer, full=%0d, empty=%0d", wdata, full, empty);
            @(posedge clk);
        end

        // assert state
        `ASSERT(empty, 0);
        `ASSERT(full, 1);

        // try writing to full buffer
        @(posedge clk);
        write = 1;
        wdata = wdata + 1;
        #1 $display("Attempted to write %0d to full buffer, full=%0d", wdata, full);
        write = 0;

        // read from buffer until empty
        $display("Reading from buffer:");
        repeat((2**ADDR_BITS)) begin
            // start read
            read = 1;
            @(posedge clk);

            // done read
            read = 0;
            #1 $display("Read %0d from buffer, full=%0d, empty=%0d", rdata, full, empty);
            @(posedge clk);
        end

        // assert state
        `ASSERT(full, 0);
        `ASSERT(empty, 1);

        // try reading from empty buffer
        @(posedge clk);
        read = 1;
        #1 $display("Attempted to read from empty buffer, rdata=%0d, empty=%0d", rdata, empty);

        #20;
        $display("Simulation time: %t", $time);
        $display("Test finished.");
        $finish;
    end

endmodule

`timescale 1ns/1ps

// first-in-first-out (FIFO) queue based on a circular buffer
module fifo
    #(
        parameter WORD_BITS=8, // number of bits in word
        parameter ADDR_BITS=4  // number of address bits (2^4 = 16 entries)
    )
    (
        input wire clk,                    // clock
        input wire reset,                  // reset
        input wire read,                   // start read from FIFO
        input wire write,                  // start write to FIFO
        input wire [WORD_BITS-1:0] wdata,  // data to write to buffer
        output wire [WORD_BITS-1:0] rdata, // data read from buffer
        output wire empty,                 // if queue is empty it can be read from
        output wire full                   // if queue is full it cannot be written to
    );

    // internal signals
    reg [WORD_BITS-1:0] buffer [2**ADDR_BITS-1:0];       // memory
    wire write_en;                                       // track if write enabled
    reg [ADDR_BITS-1:0] wptr_curr, wptr_buff, wptr_next; // track head of queue
    reg [ADDR_BITS-1:0] rptr_curr, rptr_buff, rptr_next; // track tail of queue
    reg fifo_full, full_buff;                            // track if FIFO is full
    reg fifo_empty, empty_buff;                          // track if FIFO is empty
    
    // write data to buffer
    always @(posedge clk) begin
        if (write_en) begin
            buffer[wptr_curr] <= wdata;
        end
    end

    // read data from buffer
    assign rdata = buffer[rptr_curr];

    // write enable only when buffer not full
    assign write_en = write & ~fifo_full;

    // FIFO control logic (register logic)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            wptr_curr <= 0;
            rptr_curr <= 0;
            fifo_full <= 1'b0;
            fifo_empty <= 1'b1;
        end else begin
            wptr_curr <= wptr_buff;
            rptr_curr <= rptr_buff;
            fifo_full <= full_buff;
            fifo_empty <= empty_buff;
        end
    end

    // next state for read/write pointers
    always @* begin
        wptr_next = wptr_curr + 1;
        rptr_next = rptr_curr + 1;

        // default behavior
        wptr_buff = wptr_curr;
        rptr_buff = rptr_curr;
        full_buff = fifo_full;
        empty_buff = fifo_empty;

        // handle operations
        case ({write, read})
            // no read or write
            // 2'b00

            // read
            2'b01: 
                // only read if not empty
                if (~fifo_empty) begin
                    rptr_buff = rptr_next;
                    full_buff = 1'b0; // after read, no longer full

                    // check if next read pointer wraps around to write pointer
                    if (rptr_next == wptr_curr) begin
                        empty_buff = 1'b1;
                    end
                end

            // write
            2'b10:
                // only write if not full
                if (~fifo_full) begin
                    wptr_buff = wptr_next;
                    empty_buff = 1'b0; // after write, no longer empty

                    // check if next write pointer wraps around to read pointer
                    if (wptr_next == rptr_curr) begin
                        full_buff = 1'b1;
                    end
                end

            // read and write
            2'b11:
                begin
                    wptr_buff = wptr_next; // advance write pointer
                    rptr_buff = rptr_next; // advance read pointer
                end
        endcase
    end

    // output
    assign full = fifo_full;
    assign empty = fifo_empty;

endmodule

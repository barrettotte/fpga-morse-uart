// first-in-first-out (FIFO) queue based on a circular buffer

module fifo
    #(
        parameter WORD_BITS=8, // number of bits in word
        parameter ADDR_BITS=4  // number of address bits (2^4=16)
    )
    (
        input wire i_clk,                       // clock
        input wire i_reset,                     // reset
        input wire i_rd,                        // read operation
        input wire i_wr,                        // write operation
        input wire [WORD_BITS-1:0] i_wdata,     // data to write to buffer
        output wire o_empty,                    // if queue is empty it can be read from
        output wire o_full,                     // if queue is full it cannot be written to
        output wire [WORD_BITS-1:0] o_rdata     // data read from buffer
    );

    // internal signals
    reg [WORD_BITS-1:0] reg_file [2**ADDR_BITS-1:0]; // buffer
    reg [ADDR_BITS-1:0] wptr_reg, wptr_next;         // track head of queue
    reg [ADDR_BITS-1:0] rptr_reg, rptr_next;         // track tail of queue
    reg full_reg, full_next;                         // track if buffer full
    reg empty_reg, empty_next;                       // track if buffer empty
    wire wr_en;                                      // track if write enabled

    // write data to buffer
    always @(posedge i_clk) begin
        if (wr_en) begin
            reg_file[wptr_reg] <= i_wdata;
        end
    end

    // read data from buffer
    assign o_rdata = reg_file[rptr_reg];

    // write enable only when buffer not full
    assign wr_en = i_wr & ~full_reg;

    // set state for read/write pointers
    always @(posedge i_clk, posedge i_reset) begin
        if (i_reset) begin
            wptr_reg <= 0;
            rptr_reg <= 0;
            full_reg <= 1'b0;
            empty_reg <= 1'b1;
        end
        else begin
            wptr_reg <= wptr_next;
            rptr_reg <= rptr_next;
            full_reg <= full_next;
            empty_reg <= empty_next;
        end
    end

    // next state for read/write pointers
    always @* begin
        // default behavior
        wptr_next = wptr_reg;
        rptr_next = rptr_reg;
        full_next = full_reg;
        empty_next = empty_reg;

        // handle operations
        case ({i_wr, i_rd})
            // nop
            // 2'b00

            // read
            2'b01: 
                // only read if not empty
                if (~empty_reg) begin
                    rptr_next = rptr_reg + 1;
                    full_next = 1'b0;

                    // check if next read pointer wraps around to write pointer
                    if (rptr_next == wptr_reg) begin
                        empty_next = 1'b1;
                    end
                end

            // write
            2'b10:
                // only write if not full
                if (~full_reg) begin
                    wptr_next = wptr_reg + 1;
                    empty_next = 1'b0;

                    // check if next write pointer wraps around to read pointer
                    if (wptr_next == rptr_reg) begin
                        full_next = 1'b1;
                    end
                end

            // read and write
            2'b11:
                begin
                    wptr_next = wptr_reg + 1; // advance write pointer
                    rptr_next = rptr_reg + 1; // advance read pointer
                end
        endcase
    end

    // output
    assign o_full = full_reg;
    assign o_empty = empty_reg;

endmodule

`timescale 1ns/1ps

module seven_seg_controller
    #(
        parameter REFRESH_FREQ = 1000,   // rate that each digit gets refreshed per second
                                         // default: 1000 = 1KHz = 1ms
        parameter CLK_FREQ = 100_000_000 // clock rate
    )
    (
        input wire clk_i,         // clock
        input wire reset_i,       // reset
        input wire [15:0] data_i, // two byte data to display on four 7-segment displays
        output reg [6:0] segs_o,  // 7-segment lines (a-g)
        output reg [3:0] anodes_o // anode control line (active low) for each display 
    );

    // constants
    localparam MAX_COUNT = (CLK_FREQ / REFRESH_FREQ) / 4; // max counter value
    localparam COUNTER_BITS = $clog2(MAX_COUNT);          // bits needed for counter

    // wiring/regs
    reg [COUNTER_BITS-1:0] refresh_counter; // counter for multiplexing four digits
    reg [1:0] digit_sel;                    // digit selector
    reg [3:0] digit_val;                    // digit to encode to 7-segment lines

    // register logic
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            refresh_counter <= 0;
            digit_sel <= 0;
        end else if (refresh_counter >= MAX_COUNT) begin
            refresh_counter <= 0;
            digit_sel <= digit_sel + 1;
        end else begin
            refresh_counter <= refresh_counter + 1;
        end
    end

    // mulitplex digits - digit value selection and anode control
    always @(posedge clk_i or posedge reset_i) begin
        if (reset_i) begin
            anodes_o <= 4'b1111;  // all off
            digit_val <= 0;
        end else begin
            case (digit_sel)
                // digit 1
                2'b00: begin
                    anodes_o <= 4'b1110;
                    digit_val <= data_i[3:0];
                end

                // digit 2
                2'b01: begin
                    anodes_o <= 4'b1101;
                    digit_val <= data_i[7:4];
                end

                // digit 3
                2'b10: begin
                    anodes_o <= 4'b1011;
                    digit_val <= data_i[11:8];
                end

                // digit 4
                2'b11: begin
                    anodes_o <= 4'b0111;
                    digit_val <= data_i[15:12];
                end
            endcase
        end
    end

    // 7-segment encoder
    always @* begin
        case (digit_val)
            //                   abcdefg
            4'h0:    segs_o = 7'b1000000;
            4'h1:    segs_o = 7'b1111001;
            4'h2:    segs_o = 7'b0100100;
            4'h3:    segs_o = 7'b0110000;
            4'h4:    segs_o = 7'b0011001;
            4'h5:    segs_o = 7'b0010010;
            4'h6:    segs_o = 7'b0000010;
            4'h7:    segs_o = 7'b1111000;
            4'h8:    segs_o = 7'b0000000;
            4'h9:    segs_o = 7'b0010000;
            4'hA:    segs_o = 7'b0001000;
            4'hB:    segs_o = 7'b0000011;
            4'hC:    segs_o = 7'b1000110;
            4'hD:    segs_o = 7'b0100001;
            4'hE:    segs_o = 7'b0000110;
            4'hF:    segs_o = 7'b0001110;
        endcase
    end

endmodule

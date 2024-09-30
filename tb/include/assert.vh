`define assert(signal, value) \
        if (signal !== value) begin \
            $display("ASSERTION FAILED in %m: expected: %b, actual is %b", value, signal); \
            $finish; \
        end

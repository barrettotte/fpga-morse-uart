`define assert(expected, actual) \
    if (expected !== actual) begin \
        $display("ASSERTION FAILED in %m. Expected: %b, actual is %b", expected, actual); \
        $finish; \
    end

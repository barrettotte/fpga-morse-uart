`define assert(_expected, _actual) \
    if (_expected !== _actual) begin \
        $display("ASSERTION FAILED in %m. Expected %b, but got %b", _expected, _actual); \
        $finish; \
    end

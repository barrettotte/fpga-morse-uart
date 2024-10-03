`define ASSERT(_expected, _actual) \
    if (_expected !== _actual) begin \
        $display("ASSERTION FAILED in %m. Expected %b, but got %b", _expected, _actual); \
        $finish; \
    end

`define ASSERT_W_MSG(_expected, _actual, _msg) \
    $display(_msg); \
    `ASSERT(_expected, _actual); \

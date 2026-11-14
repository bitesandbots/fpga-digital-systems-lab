// gate_or - two-input OR gate: y is high when either input is high
//
// Pure combinational logic: the output is a continuous function of the inputs.
// There is no clock and no state. The `assign` below is not a step that runs -
// it describes a piece of hardware that is always computing, all the time.

`default_nettype none

module gate_or (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a | b;

endmodule

`default_nettype wire

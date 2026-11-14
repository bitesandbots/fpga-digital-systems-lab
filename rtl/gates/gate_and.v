// gate_and - two-input AND gate: y is high only when both inputs are high
//
// Pure combinational logic: the output is a continuous function of the inputs.
// There is no clock and no state. The `assign` below is not a step that runs -
// it describes a piece of hardware that is always computing, all the time.

`default_nettype none

module gate_and (
    input  wire a,
    input  wire b,
    output wire y
);

    assign y = a & b;

endmodule

`default_nettype wire

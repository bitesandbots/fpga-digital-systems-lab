// gate_not - inverter: y is the logical complement of a
//
// Pure combinational logic: the output is a continuous function of the inputs.
// There is no clock and no state. The `assign` below is not a step that runs -
// it describes a piece of hardware that is always computing, all the time.

`default_nettype none

module gate_not (
    input  wire a,
    output wire y
);

    assign y = ~a;

endmodule

`default_nettype wire

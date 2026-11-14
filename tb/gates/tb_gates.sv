// tb_gates - exhaustive self-checking testbench for the four basic gates.
//
// Drives every possible input combination and compares each output against a
// value computed independently in the testbench. Reports PASS only if every
// check matched; calls $fatal(1) otherwise so CI turns red.
//
//   4 combinations x 3 two-input gates = 12 checks
//   2 combinations x 1 inverter        =  2 checks
//                                        --
//                                        14 checks

`timescale 1ns/1ps
`default_nettype none

module tb_gates;

    // Stimulus and observed outputs. Declared explicitly because
    // `default_nettype none` disables implicit net creation - a typo'd
    // signal name becomes a compile error instead of a silent new wire.
    logic a;
    logic b;
    logic y_and;
    logic y_or;
    logic y_xor;
    logic y_not;

    int errors = 0;
    int checks = 0;
    int i;

    // --- Devices under test -------------------------------------------------
    // All four exist simultaneously. None of them "runs after" another.
    gate_and u_and (.a(a), .b(b), .y(y_and));
    gate_or  u_or  (.a(a), .b(b), .y(y_or));
    gate_xor u_xor (.a(a), .b(b), .y(y_xor));
    gate_not u_not (.a(a),        .y(y_not));

    // --- Checker ------------------------------------------------------------
    task automatic check(input string name, input logic got, input logic exp);
        checks = checks + 1;
        if (got !== exp) begin
            errors = errors + 1;
            $display("FAIL [%0s]: got=%0b expected=%0b at t=%0t", name, got, exp, $time);
        end
    endtask

    // --- Stimulus -----------------------------------------------------------
    initial begin
        $dumpfile("sim/tb_gates.vcd");
        $dumpvars(0, tb_gates);

        // Exhaustive over the two-input gates: {a,b} = 00, 01, 10, 11
        for (i = 0; i < 4; i = i + 1) begin
            a = (i >> 1) & 1'b1;
            b =  i       & 1'b1;
            #1;  // let the continuous assignments settle before sampling
            check($sformatf("and_%0b%0b", a, b), y_and, a & b);
            check($sformatf("or_%0b%0b",  a, b), y_or,  a | b);
            check($sformatf("xor_%0b%0b", a, b), y_xor, a ^ b);
        end

        // Exhaustive over the inverter: a = 0, 1
        for (i = 0; i < 2; i = i + 1) begin
            a = i & 1'b1;
            #1;
            check($sformatf("not_%0b", a), y_not, ~a);
        end

        if (errors == 0) begin
            $display("PASS: tb_gates (%0d checks)", checks);
        end
        else begin
            $display("FAIL: tb_gates - %0d/%0d checks failed", errors, checks);
            $fatal(1);
        end
        $finish;
    end

    // --- Watchdog -----------------------------------------------------------
    // A hung simulation must fail, not hang CI forever.
    initial begin
        #1000000;  // 1 ms
        $display("FAIL: tb_gates timeout");
        $fatal(1);
    end

endmodule

`default_nettype wire

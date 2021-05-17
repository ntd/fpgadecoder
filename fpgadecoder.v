/* verilator lint_off UNOPTFLAT */

// Decoding quadrature encoders with FPGA.
//
//           _______         _______
//  A ______|       |_______|       |______
//       _______         _______         __
//  B __|       |_______|       |_______|
//
// Calling `a` and `b` the current states of phase A and phase B and
// `_a` and `_b` its previous states:
//
// Forward direction ( --> )
// _a _b    a  b
// -------------
//  0  0 |  0  1
//  0  1 |  1  1
//  1  1 |  1  0
//  1  0 |  0  0
//
// Backward direction ( <-- )
// _a _b    a  b
// -------------
//  0  0 |  1  0
//  1  0 |  1  1
//  1  1 |  0  1
//  0  1 |  0  0
//
// In short, if b and _a are differents the encoder is moving forward,
// if they are equal it is moving backward. This explains why I have:
//
//      delta = b ^ _a ? +1 : -1;
//
module fpgadecoder(output reg [15:0] cnt = 0, input a, input b, input z);
    reg [15:0] delta = 0;   // Value to add to the counter
    reg _a = 0;             // Previous state of A phase
    reg _b = 0;             // Previous state of B phase
    reg achange, bchange;

    always @(a or b) begin
        achange = a ^ _a;
        bchange = b ^ _b;
        if (achange & bchange) begin
            // Both phases changed: rotation too quick! Add `delta`
            // twice because at least one step has been skipped
            cnt += delta + delta;
        end else if (achange | bchange) begin
            // Only one phase changed: one step rotation (common case)
            delta = b ^ _a ? +1 : -1;
            cnt += delta;
        end
        // The no changes condition (both `achange` and `bchange` are
        // OFF) is not handled because (1) it should never happen and
        // (2) when it happens, I do not know what to do
        _a = a;
        _b = b;
    end

    always @(posedge z) begin
        cnt = 0;
    end
endmodule

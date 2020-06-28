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
// In short, if b and _a are different the encoder is moving forward,
// if they are equal it is moving backward. Translated in Verilog:
//
//      forward = b ^ _a;
//
module decoder(output [15:0] cnt, input a, input b, input z);
    reg [15:0] cnt = 0;
    reg forward = 0;// Current direction, used when a step is skipped
    reg _a = 0;     // Previous state of a phase
    reg _b = 0;     // Previous state of b phase
    reg achange, bchange;

    always @(a or b) begin
        // Not sure this is the best way to reuse expressions
        achange = a ^ _a;
        bchange = b ^ _b;
        if (achange & bchange) begin
            // Rotation too quick: one step skipped
            cnt <= forward ? cnt + 2 : cnt - 2;
        end else if (achange | bchange) begin
            // Normal rotation
            forward = b ^ _a;
            cnt <= forward ? cnt + 1 : cnt - 1;
        end
        _a <= a;
        _b <= b;
    end

    always @(posedge z) begin
        cnt <= 0;
    end
endmodule

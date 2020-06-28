module fpgadecoder_tb;
    reg a, b, z;
    wire signed [15:0] cnt;

    initial begin
        $display("A B Z");
        $monitor("%b %b %b %d", a, b, z, cnt);

        a = 0;
        b = 0;
        z = 0;

        // Test forward direction
        #5 b = 1;
        #5 a = 1;
        #5 b = 0;
        #5 a = 0;

        // Test backward direction
        #5 a = 1;
        #5 b = 1;
        #5 a = 0;
        #5 b = 0;

        // Test step skipping
        #5 a = 1; b = 1;
        #5 a = 0; b = 0;
        #5 b = 1; // Now move forward
        #5 a = 1; b = 0;
        #5 a = 0; b = 1;

        // Reset
        #5 z = 1;
        #5 b = 0;
        #5 z = 0;

        #5 $finish;
    end

    fpgadecoder U0 (
        .cnt (cnt),
        .a (a),
        .b (b),
        .z (z)
    );
endmodule

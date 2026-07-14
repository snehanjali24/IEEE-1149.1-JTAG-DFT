
`timescale 1ns/1ps
//==============================================================================
// Project     : IEEE 1149.1 JTAG Boundary Scan
// Module      : tb_multiplier
// Description : Self-checking exhaustive testbench for 4x4 Multiplier
// Author      : Akhil
//==============================================================================

`timescale 1ns/1ps
//==============================================================================
// Project     : IEEE 1149.1 JTAG Boundary Scan
// Module      : tb_multiplier
// Description : Self-Checking Testbench for 4x4 Multiplier
//==============================================================================

module tb_multiplier;

localparam WIDTH = 4;

//--------------------------------------------------------------------------
// Testbench Signals
//--------------------------------------------------------------------------

reg  [WIDTH-1:0] a;
reg  [WIDTH-1:0] b;
wire [2*WIDTH-1:0] product;

integer errors;
integer total_tests;
integer i,j;

reg [2*WIDTH-1:0] expected;

//--------------------------------------------------------------------------
// DUT
//--------------------------------------------------------------------------

multiplier_4x4 #(
    .WIDTH(WIDTH)
)
dut
(
    .a(a),
    .b(b),
    .product(product)
);

//--------------------------------------------------------------------------
// Test Sequence
//--------------------------------------------------------------------------

initial
begin

    a = 0;
    b = 0;

    errors      = 0;
    total_tests = 0;

    $display("\n====================================================");
    $display("         4x4 MULTIPLIER VERIFICATION");
    $display("====================================================");

    //----------------------------------------------------------------------
    // Exhaustive Verification
    //----------------------------------------------------------------------

    for(i=0;i<16;i=i+1)
    begin
        for(j=0;j<16;j=j+1)
        begin

            a = i;
            b = j;

            #10;

            expected = i*j;

            total_tests = total_tests + 1;

            if(product !== expected)
            begin
                errors = errors + 1;

                $display("[FAIL] A=%0d B=%0d Expected=%0d Got=%0d",
                         a,b,expected,product);
            end

        end
    end

    //----------------------------------------------------------------------
    // Corner Cases
    //----------------------------------------------------------------------

    a = 4'd0;  b = 4'd0;  #10;
    if(product != 8'd0)
    begin
        errors = errors + 1;
        $display("[FAIL] Corner Case : 0 x 0");
    end

    a = 4'd15; b = 4'd15; #10;
    if(product != 8'd225)
    begin
        errors = errors + 1;
        $display("[FAIL] Corner Case : 15 x 15");
    end

    a = 4'd1; b = 4'd15; #10;
    if(product != 8'd15)
    begin
        errors = errors + 1;
        $display("[FAIL] Corner Case : 1 x 15");
    end

    a = 4'd15; b = 4'd1; #10;
    if(product != 8'd15)
    begin
        errors = errors + 1;
        $display("[FAIL] Corner Case : 15 x 1");
    end

    //----------------------------------------------------------------------
    // Summary
    //----------------------------------------------------------------------

    $display("\n====================================================");

    if(errors==0)
        $display(" RESULT        : ALL TEST CASES PASSED");
    else
        $display(" RESULT        : TEST FAILED");

    $display(" TOTAL TESTS   : %0d",total_tests);
    $display(" ERRORS        : %0d",errors);

    $display("====================================================\n");

    $finish;

end

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:58:26
// Design Name: 
// Module Name: tb_bypass_register
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps
//==============================================================================
// Project     : IEEE 1149.1 JTAG Boundary Scan
// Module      : tb_bypass_register
// Description : Self-Checking Testbench for BYPASS Register
// Author      : Akhil
//==============================================================================

module tb_bypass_register;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg  tck;
    reg  trst_n;

    reg  capture_dr;
    reg  shift_dr;

    reg  tdi;
    wire tdo;

    integer errors;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    bypass_register dut
    (
        .tck        (tck),
        .trst_n     (trst_n),
        .capture_dr (capture_dr),
        .shift_dr   (shift_dr),
        .tdi        (tdi),
        .tdo        (tdo)
    );

    //--------------------------------------------------------------------------
    // Clock Generation
    //--------------------------------------------------------------------------

    initial
        tck = 0;

    always
        #5 tck = ~tck;

    //--------------------------------------------------------------------------
    // Check Task
    //--------------------------------------------------------------------------

    task automatic check;

        input cond;
        input [255:0] msg;

        begin

            if(!cond)
            begin
                $display("[FAIL] %0s (Time = %0t)", msg, $time);
                errors = errors + 1;
            end

        end

    endtask

    //--------------------------------------------------------------------------
    // Optional VCD Dump (GTKWave / Icarus)
    //--------------------------------------------------------------------------

    initial
    begin
        $dumpfile("tb_bypass_register.vcd");
        $dumpvars(0,tb_bypass_register);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial
    begin

        errors = 0;

        trst_n     = 0;
        capture_dr = 0;
        shift_dr   = 0;
        tdi        = 1'b0;

        $display("\n====================================================");
        $display("         BYPASS REGISTER VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // Reset Verification
        //----------------------------------------------------------------------

        @(negedge tck);

        trst_n = 1;

        #1;

        check(tdo == 1'b0,
              "Reset : TDO should be 0");

        if(errors==0)
            $display("[PASS] Reset");

        //----------------------------------------------------------------------
        // Capture-DR Verification
        //----------------------------------------------------------------------

        tdi = 1'b1;

        capture_dr = 1'b1;

        @(posedge tck);

        #1;

        capture_dr = 1'b0;

        check(tdo == 1'b0,
              "Capture-DR : BYPASS must capture fixed 0");

        if(errors==0)
            $display("[PASS] Capture-DR");

        //----------------------------------------------------------------------
        // Shift-DR Verification
        //----------------------------------------------------------------------

        shift_dr = 1'b1;

        // Shift in '1'

        tdi = 1'b1;

        @(posedge tck);

        #1;

        check(tdo == 1'b1,
              "Shift-DR : TDO should equal delayed TDI = 1");

        // Shift in '0'

        tdi = 1'b0;

        @(posedge tck);

        #1;

        check(tdo == 1'b0,
              "Shift-DR : TDO should equal delayed TDI = 0");

        // Shift in '1'

        tdi = 1'b1;

        @(posedge tck);

        #1;

        check(tdo == 1'b1,
              "Shift-DR : Second delayed TDI = 1");

        shift_dr = 1'b0;

        if(errors==0)
            $display("[PASS] Shift-DR");

        //----------------------------------------------------------------------
        // Asynchronous Reset
        //----------------------------------------------------------------------

        trst_n = 1'b0;

        #1;

        check(tdo == 1'b0,
              "Async Reset : TDO should clear");

        trst_n = 1'b1;

        if(errors==0)
            $display("[PASS] Asynchronous Reset");

        //----------------------------------------------------------------------
        // Summary
        //----------------------------------------------------------------------

        $display("\n====================================================");

        if(errors==0)
        begin
            $display(" RESULT        : ALL TEST CASES PASSED");
        end
        else
        begin
            $display(" RESULT        : TEST FAILED");
        end

        $display(" ERRORS        : %0d", errors);

        $display("====================================================\n");

        $finish;

    end

endmodule

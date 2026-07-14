`timescale 1ns/1ps
//==============================================================================
// Project     : IEEE 1149.1 JTAG Boundary Scan
// Module      : tb_boundary_scan_cell
// Description : Self-checking Testbench for Boundary Scan Cell
// Author      : Akhil
//==============================================================================

module tb_boundary_scan_cell;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg  tck;
    reg  trst_n;

    reg  capture_dr;
    reg  shift_dr;
    reg  update_dr;

    reg  mode_extest;

    reg  si;
    reg  pi;

    wire so;
    wire po;

    integer errors;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    boundary_scan_cell dut
    (
        .tck         (tck),
        .trst_n      (trst_n),
        .capture_dr  (capture_dr),
        .shift_dr    (shift_dr),
        .update_dr   (update_dr),
        .mode_extest (mode_extest),
        .si          (si),
        .pi          (pi),
        .so          (so),
        .po          (po)
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
                $display("[FAIL] %0s (Time = %0t)",msg,$time);
                errors = errors + 1;
            end

        end

    endtask

    //--------------------------------------------------------------------------
    // Optional VCD Dump
    //--------------------------------------------------------------------------

    initial
    begin
        $dumpfile("tb_boundary_scan_cell.vcd");
        $dumpvars(0,tb_boundary_scan_cell);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial
    begin

        errors = 0;

        trst_n      = 0;

        capture_dr  = 0;
        shift_dr    = 0;
        update_dr   = 0;

        mode_extest = 0;

        si = 0;
        pi = 0;

        $display("\n====================================================");
        $display("        BOUNDARY SCAN CELL VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // 1. Reset Verification
        //----------------------------------------------------------------------

        @(negedge tck);

        trst_n = 1;

        @(posedge tck);

        #1;

        check(so==1'b0,"Reset : SO should be 0");

        if(errors==0)
            $display("[PASS] Reset");

        //----------------------------------------------------------------------
        // 2. Capture-DR
        //----------------------------------------------------------------------

        pi = 1'b1;

        capture_dr = 1;

        @(posedge tck);

        #1;

        capture_dr = 0;

        check(so==1'b1,"Capture-DR : SO should capture PI");

        if(errors==0)
            $display("[PASS] Capture-DR");

        //----------------------------------------------------------------------
        // 3. Shift-DR
        //----------------------------------------------------------------------

        shift_dr = 1;

        si = 0;

        @(posedge tck);

        #1;

        check(so==0,"Shift-DR : SO should shift SI=0");

        si = 1;

        @(posedge tck);

        #1;

        check(so==1,"Shift-DR : SO should shift SI=1");

        shift_dr = 0;

        if(errors==0)
            $display("[PASS] Shift-DR");

        //----------------------------------------------------------------------
        // 4. Update-DR
        //----------------------------------------------------------------------

        update_dr = 1;

        @(posedge tck);

        #1;

        update_dr = 0;

        mode_extest = 1;

        pi = 0;

        #1;

        check(po==1,"EXTEST : PO should equal Update Register");

        if(errors==0)
            $display("[PASS] Update-DR / EXTEST");

        //----------------------------------------------------------------------
        // 5. Functional Mode
        //----------------------------------------------------------------------

        mode_extest = 0;

        pi = 0;

        #1;

        check(po==0,"Functional Mode : PO should follow PI=0");

        pi = 1;

        #1;

        check(po==1,"Functional Mode : PO should follow PI=1");

        if(errors==0)
            $display("[PASS] Functional Mode");

        //----------------------------------------------------------------------
        // 6. Shift New Value + Update
        //----------------------------------------------------------------------

        shift_dr = 1;

        si = 0;

        @(posedge tck);

        #1;

        shift_dr = 0;

        update_dr = 1;

        @(posedge tck);

        #1;

        update_dr = 0;

        mode_extest = 1;

        pi = 1;

        #1;

        check(po==0,"EXTEST : Updated value should drive output");

        if(errors==0)
            $display("[PASS] New Update Value");

        //----------------------------------------------------------------------
        // 7. Asynchronous Reset
        //----------------------------------------------------------------------

        trst_n = 0;

        #1;

        check(so==0,"Async Reset : SO should clear");

        trst_n = 1;

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

        $display(" ERRORS        : %0d",errors);

        $display("====================================================\n");

        $finish;

    end

endmodule

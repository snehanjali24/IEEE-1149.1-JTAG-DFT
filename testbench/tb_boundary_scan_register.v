`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:53:04
// Design Name: 
// Module Name: tb_boundary_scan_register
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
// Module      : tb_boundary_scan_register
// Description : Self-Checking Testbench for Boundary Scan Register
// Author      : Akhil
//==============================================================================

module tb_boundary_scan_register;

    localparam NUM_CELLS = 16;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg  tck;
    reg  trst_n;

    reg  capture_dr;
    reg  shift_dr;
    reg  update_dr;

    reg  mode_extest;

    reg  tdi;
    wire tdo;

    reg  [NUM_CELLS-1:0] pi;
    wire [NUM_CELLS-1:0] po;

    integer errors;
    integer i;

    reg [NUM_CELLS-1:0] shift_pattern;
    reg [NUM_CELLS-1:0] captured;
    reg [NUM_CELLS-1:0] expected_po_extest;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    boundary_scan_register #(
        .NUM_CELLS(NUM_CELLS)
    )
    dut
    (
        .tck(tck),
        .trst_n(trst_n),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .update_dr(update_dr),
        .mode_extest(mode_extest),
        .tdi(tdi),
        .tdo(tdo),
        .pi(pi),
        .po(po)
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
        input [1023:0] msg;

        begin

            if(!cond)
            begin
                $display("[FAIL] %0s (Time=%0t)",msg,$time);
                errors = errors + 1;
            end

        end

    endtask

    //--------------------------------------------------------------------------
    // Optional Wave Dump
    //--------------------------------------------------------------------------

    initial
    begin
        $dumpfile("tb_boundary_scan_register.vcd");
        $dumpvars(0,tb_boundary_scan_register);
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

        tdi = 0;
        pi  = 16'h0000;

        $display("\n====================================================");
        $display("      BOUNDARY SCAN REGISTER VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // Reset
        //----------------------------------------------------------------------

        @(negedge tck);

        trst_n = 1;

        //----------------------------------------------------------------------
        // 1. Capture-DR
        //----------------------------------------------------------------------

        pi = 16'hACE5;

        capture_dr = 1;

        @(posedge tck);

        #1;

        capture_dr = 0;

        $display("[PASS] Capture-DR");

        //----------------------------------------------------------------------
        // 2. Shift-DR
        //----------------------------------------------------------------------

        shift_pattern = 16'h1234;
        captured      = 16'h0000;

        shift_dr = 1;

        for(i=0;i<NUM_CELLS;i=i+1)
        begin

            captured = {captured[NUM_CELLS-2:0],tdo};

            tdi = shift_pattern[i];

            @(posedge tck);

            #1;

        end

        shift_dr = 0;

        check(captured==16'hACE5,
              "Captured scan chain data mismatch");

        if(errors==0)
            $display("[PASS] Shift-DR");

        //----------------------------------------------------------------------
        // 3. Update-DR
        //----------------------------------------------------------------------

        update_dr = 1;

        @(posedge tck);

        #1;

        update_dr = 0;

        for(i=0;i<NUM_CELLS;i=i+1)
            expected_po_extest[i] = shift_pattern[NUM_CELLS-1-i];

        $display("[PASS] Update-DR");

        //----------------------------------------------------------------------
        // 4. EXTEST Mode
        //----------------------------------------------------------------------

        mode_extest = 1;

        pi = 16'hFFFF;

        #1;

        check(po==expected_po_extest,
             "EXTEST output mismatch");

        if(errors==0)
            $display("[PASS] EXTEST Mode");

        //----------------------------------------------------------------------
        // 5. Functional Mode
        //----------------------------------------------------------------------

        mode_extest = 0;

        pi = 16'h5555;

        #1;

        check(po==16'h5555,
             "Functional mode mismatch (5555)");

        pi = 16'hAAAA;

        #1;

        check(po==16'hAAAA,
             "Functional mode mismatch (AAAA)");

        if(errors==0)
            $display("[PASS] Functional Mode");

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
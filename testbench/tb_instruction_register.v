`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 10:20:24
// Design Name: 
// Module Name: tb_instruction_register
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
// Module      : tb_instruction_register
// Description : Self-Checking Testbench for Instruction Register
// Author      : Akhil
//==============================================================================

module tb_instruction_register;

    parameter IR_WIDTH = 3;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg                  tck;
    reg                  trst_n;

    reg                  capture_ir;
    reg                  shift_ir;
    reg                  update_ir;

    reg                  tdi;

    wire                 tdo;
    wire [IR_WIDTH-1:0]  ir_out;

    integer errors;
    integer i;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    instruction_register #(
        .IR_WIDTH(IR_WIDTH)
    )
    dut
    (
        .tck(tck),
        .trst_n(trst_n),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .update_ir(update_ir),
        .tdi(tdi),
        .tdo(tdo),
        .ir_out(ir_out)
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
                errors = errors + 1;
                $display("[FAIL] %0s (Time=%0t)",msg,$time);
            end
        end

    endtask

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial
    begin

        errors = 0;

        trst_n     = 0;
        capture_ir = 0;
        shift_ir   = 0;
        update_ir  = 0;
        tdi        = 0;

        $display("\n====================================================");
        $display("        INSTRUCTION REGISTER VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // Reset
        //----------------------------------------------------------------------

        @(negedge tck);

        trst_n = 1;

        #1;

        check(ir_out == 3'b111,
              "Reset : IR should initialize to BYPASS (111)");

        if(errors==0)
            $display("[PASS] Reset");

        //----------------------------------------------------------------------
        // Capture-IR
        //----------------------------------------------------------------------

        capture_ir = 1;

        @(posedge tck);

        #1;

        capture_ir = 0;

        check(tdo == 1'b1,
              "Capture-IR : Capture pattern should be 001");

        if(errors==0)
            $display("[PASS] Capture-IR");

        //----------------------------------------------------------------------
        // Shift-IR
        // Shift in 000 (LSB first)
        //----------------------------------------------------------------------

        shift_ir = 1;

        tdi = 0;
        @(posedge tck); #1;

        tdi = 0;
        @(posedge tck); #1;

        tdi = 0;
        @(posedge tck); #1;

        shift_ir = 0;

        if(errors==0)
            $display("[PASS] Shift-IR");

        //----------------------------------------------------------------------
        // Update-IR
        //----------------------------------------------------------------------

        update_ir = 1;

        @(posedge tck);

        #1;

        update_ir = 0;

        check(ir_out == 3'b000,
              "Update-IR : Instruction should become EXTEST (000)");

        if(errors==0)
            $display("[PASS] Update-IR");

        //----------------------------------------------------------------------
        // Verify Another Instruction (BYPASS = 111)
        //----------------------------------------------------------------------

        shift_ir = 1;

        for(i=0;i<3;i=i+1)
        begin
            tdi = 1'b1;
            @(posedge tck);
            #1;
        end

        shift_ir = 0;

        update_ir = 1;

        @(posedge tck);

        #1;

        update_ir = 0;

        check(ir_out == 3'b111,
              "Instruction should update to BYPASS (111)");

        if(errors==0)
            $display("[PASS] BYPASS Instruction");

        //----------------------------------------------------------------------
        // Summary
        //----------------------------------------------------------------------

        $display("\n====================================================");

        if(errors==0)
            $display(" RESULT        : ALL TEST CASES PASSED");
        else
            $display(" RESULT        : TEST FAILED");

        $display(" ERRORS        : %0d",errors);

        $display("====================================================\n");

        $finish;

    end

endmodule

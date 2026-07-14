`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:57:22
// Design Name: 
// Module Name: tb_tap_controller
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
// Module      : tb_tap_controller
// Description : Self-Checking Testbench for TAP Controller FSM
// Author      : Akhil
//==============================================================================

module tb_tap_controller;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg tck;
    reg tms;
    reg trst_n;

    wire [3:0] tap_state;

    wire test_logic_reset;
    wire run_test_idle;
    wire select_dr_scan;
    wire capture_dr;
    wire shift_dr;
    wire exit1_dr;
    wire pause_dr;
    wire exit2_dr;
    wire update_dr;

    wire select_ir_scan;
    wire capture_ir;
    wire shift_ir;
    wire exit1_ir;
    wire pause_ir;
    wire exit2_ir;
    wire update_ir;

    integer errors;

    //--------------------------------------------------------------------------
    // TAP State Encoding
    //--------------------------------------------------------------------------

    localparam [3:0]
        TEST_LOGIC_RESET = 4'd0,
        RUN_TEST_IDLE    = 4'd1,
        SELECT_DR_SCAN   = 4'd2,
        CAPTURE_DR       = 4'd3,
        SHIFT_DR         = 4'd4,
        EXIT1_DR         = 4'd5,
        PAUSE_DR         = 4'd6,
        EXIT2_DR         = 4'd7,
        UPDATE_DR        = 4'd8,
        SELECT_IR_SCAN   = 4'd9,
        CAPTURE_IR       = 4'd10,
        SHIFT_IR         = 4'd11,
        EXIT1_IR         = 4'd12,
        PAUSE_IR         = 4'd13,
        EXIT2_IR         = 4'd14,
        UPDATE_IR        = 4'd15;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    tap_controller dut
    (
        .tck(tck),
        .tms(tms),
        .trst_n(trst_n),

        .tap_state(tap_state),

        .test_logic_reset(test_logic_reset),
        .run_test_idle(run_test_idle),
        .select_dr_scan(select_dr_scan),
        .capture_dr(capture_dr),
        .shift_dr(shift_dr),
        .exit1_dr(exit1_dr),
        .pause_dr(pause_dr),
        .exit2_dr(exit2_dr),
        .update_dr(update_dr),

        .select_ir_scan(select_ir_scan),
        .capture_ir(capture_ir),
        .shift_ir(shift_ir),
        .exit1_ir(exit1_ir),
        .pause_ir(pause_ir),
        .exit2_ir(exit2_ir),
        .update_ir(update_ir)
    );

    //--------------------------------------------------------------------------
    // Clock Generation
    //--------------------------------------------------------------------------

    initial
        tck = 0;

    always
        #5 tck = ~tck;

    //--------------------------------------------------------------------------
    // Automatic Step Task
    //--------------------------------------------------------------------------

    task automatic step;

        input tms_val;
        input [3:0] expected_state;
        input [255:0] msg;

        begin

            tms = tms_val;

            @(posedge tck);

            #1;

            if(tap_state !== expected_state)
            begin

                $display("[FAIL] %0s",msg);
                $display("       Expected = %0d",expected_state);
                $display("       Got      = %0d",tap_state);

                errors = errors + 1;

            end

        end

    endtask

    //--------------------------------------------------------------------------
    // Optional Wave Dump
    //--------------------------------------------------------------------------

    initial
    begin
        $dumpfile("tb_tap_controller.vcd");
        $dumpvars(0,tb_tap_controller);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial
    begin

        errors = 0;

        trst_n = 0;
        tms    = 1;

        $display("\n====================================================");
        $display("         TAP CONTROLLER VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // Reset
        //----------------------------------------------------------------------

        @(negedge tck);

        trst_n = 1;

        #1;

        if(tap_state != TEST_LOGIC_RESET)
        begin
            $display("[FAIL] Reset failed");
            errors = errors + 1;
        end
        else
            $display("[PASS] Reset");

        //----------------------------------------------------------------------
        // DR Path
        //----------------------------------------------------------------------

        step(0,RUN_TEST_IDLE,"TLR -> RTI");
        step(1,SELECT_DR_SCAN,"RTI -> SELECT_DR");
        step(0,CAPTURE_DR,"SELECT_DR -> CAPTURE_DR");
        step(0,SHIFT_DR,"CAPTURE_DR -> SHIFT_DR");
        step(0,SHIFT_DR,"SHIFT_DR Self Loop");
        step(1,EXIT1_DR,"SHIFT_DR -> EXIT1_DR");
        step(0,PAUSE_DR,"EXIT1_DR -> PAUSE_DR");
        step(0,PAUSE_DR,"PAUSE_DR Self Loop");
        step(1,EXIT2_DR,"PAUSE_DR -> EXIT2_DR");
        step(0,SHIFT_DR,"EXIT2_DR -> SHIFT_DR");
        step(1,EXIT1_DR,"SHIFT_DR -> EXIT1_DR");
        step(1,UPDATE_DR,"EXIT1_DR -> UPDATE_DR");
        step(0,RUN_TEST_IDLE,"UPDATE_DR -> RTI");

        if(errors==0)
            $display("[PASS] Complete DR Scan Path");

        //----------------------------------------------------------------------
        // IR Path
        //----------------------------------------------------------------------

        step(1,SELECT_DR_SCAN,"RTI -> SELECT_DR");
        step(1,SELECT_IR_SCAN,"SELECT_DR -> SELECT_IR");
        step(0,CAPTURE_IR,"SELECT_IR -> CAPTURE_IR");
        step(0,SHIFT_IR,"CAPTURE_IR -> SHIFT_IR");
        step(0,SHIFT_IR,"SHIFT_IR Self Loop");
        step(1,EXIT1_IR,"SHIFT_IR -> EXIT1_IR");
        step(0,PAUSE_IR,"EXIT1_IR -> PAUSE_IR");
        step(0,PAUSE_IR,"PAUSE_IR Self Loop");
        step(1,EXIT2_IR,"PAUSE_IR -> EXIT2_IR");
        step(0,SHIFT_IR,"EXIT2_IR -> SHIFT_IR");
        step(1,EXIT1_IR,"SHIFT_IR -> EXIT1_IR");
        step(1,UPDATE_IR,"EXIT1_IR -> UPDATE_IR");
        step(0,RUN_TEST_IDLE,"UPDATE_IR -> RTI");

        if(errors==0)
            $display("[PASS] Complete IR Scan Path");

        //----------------------------------------------------------------------
        // Shortcut DR Path
        //----------------------------------------------------------------------

        step(1,SELECT_DR_SCAN,"RTI -> SELECT_DR");
        step(0,CAPTURE_DR,"SELECT_DR -> CAPTURE_DR");
        step(1,EXIT1_DR,"CAPTURE_DR -> EXIT1_DR");
        step(1,UPDATE_DR,"EXIT1_DR -> UPDATE_DR");
        step(0,RUN_TEST_IDLE,"UPDATE_DR -> RTI");

        if(errors==0)
            $display("[PASS] Shortcut DR Path");

        //----------------------------------------------------------------------
        // Return to Test Logic Reset
        //----------------------------------------------------------------------

        step(1,SELECT_DR_SCAN,"RTI -> SELECT_DR");
        step(1,SELECT_IR_SCAN,"SELECT_DR -> SELECT_IR");
        step(1,TEST_LOGIC_RESET,"SELECT_IR -> RESET");
        step(1,TEST_LOGIC_RESET,"RESET Self Loop");
        step(1,TEST_LOGIC_RESET,"RESET Self Loop");

        if(errors==0)
            $display("[PASS] Return to Reset");

        //----------------------------------------------------------------------
        // Asynchronous Reset
        //----------------------------------------------------------------------

        step(0,RUN_TEST_IDLE,"RESET -> RTI");
        step(1,SELECT_DR_SCAN,"RTI -> SELECT_DR");

        trst_n = 0;

        #1;

        if(tap_state != TEST_LOGIC_RESET)
        begin
            $display("[FAIL] Asynchronous Reset");
            errors = errors + 1;
        end
        else
            $display("[PASS] Asynchronous Reset");

        trst_n = 1;

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

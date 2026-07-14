`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:54:58
// Design Name: 
// Module Name: tb_instruction_decoder
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
// Module      : tb_instruction_decoder
// Description : Self-Checking Testbench for Instruction Decoder
// Author      : Akhil
//==============================================================================

module tb_instruction_decoder;

    localparam IR_WIDTH = 3;

    //--------------------------------------------------------------------------
    // Testbench Signals
    //--------------------------------------------------------------------------

    reg  [IR_WIDTH-1:0] ir_out;

    wire mode_extest;
    wire sample_preload_sel;
    wire bypass_sel;

    integer errors;
    integer total_tests;
    integer i;

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------

    instruction_decoder #(
        .IR_WIDTH(IR_WIDTH)
    )
    dut
    (
        .ir_out(ir_out),
        .mode_extest(mode_extest),
        .sample_preload_sel(sample_preload_sel),
        .bypass_sel(bypass_sel)
    );

    //--------------------------------------------------------------------------
    // Optional Wave Dump
    //--------------------------------------------------------------------------

    initial
    begin
        $dumpfile("tb_instruction_decoder.vcd");
        $dumpvars(0,tb_instruction_decoder);
    end

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------

    initial
    begin

        errors      = 0;
        total_tests = 0;

        $display("\n====================================================");
        $display("      INSTRUCTION DECODER VERIFICATION");
        $display("====================================================");

        //----------------------------------------------------------------------
        // Verify all possible instructions
        //----------------------------------------------------------------------

        for(i=0;i<8;i=i+1)
        begin

            ir_out = i[IR_WIDTH-1:0];

            #10;

            total_tests = total_tests + 1;

            case(i)

                //--------------------------------------------------------------
                // EXTEST
                //--------------------------------------------------------------

                3'b000:
                begin

                    if(!(mode_extest &&
                         !sample_preload_sel &&
                         !bypass_sel))
                    begin
                        $display("[FAIL] EXTEST Decode Error : IR = %03b",ir_out);
                        errors = errors + 1;
                    end

                end

                //--------------------------------------------------------------
                // SAMPLE / PRELOAD
                //--------------------------------------------------------------

                3'b001:
                begin

                    if(!(!mode_extest &&
                          sample_preload_sel &&
                         !bypass_sel))
                    begin
                        $display("[FAIL] SAMPLE/PRELOAD Decode Error : IR = %03b",ir_out);
                        errors = errors + 1;
                    end

                end

                //--------------------------------------------------------------
                // BYPASS
                //--------------------------------------------------------------

                3'b111:
                begin

                    if(!(!mode_extest &&
                         !sample_preload_sel &&
                          bypass_sel))
                    begin
                        $display("[FAIL] BYPASS Decode Error : IR = %03b",ir_out);
                        errors = errors + 1;
                    end

                end

                //--------------------------------------------------------------
                // Reserved Instructions
                //--------------------------------------------------------------

                default:
                begin

                    if(!(!mode_extest &&
                         !sample_preload_sel &&
                          bypass_sel))
                    begin
                        $display("[FAIL] Reserved Opcode Decode Error : IR = %03b",ir_out);
                        errors = errors + 1;
                    end

                end

            endcase

            //--------------------------------------------------------------
            // One-Hot Decode Check
            //--------------------------------------------------------------

            if((mode_extest +
                sample_preload_sel +
                bypass_sel) != 1)
            begin

                $display("[FAIL] Invalid Decoder Output Combination : IR = %03b",
                          ir_out);

                errors = errors + 1;

            end

        end

        //----------------------------------------------------------------------
        // PASS Message
        //----------------------------------------------------------------------

        if(errors==0)
            $display("[PASS] All 8 Instruction Opcodes Verified");

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

        $display(" TOTAL TESTS   : %0d",total_tests);
        $display(" ERRORS        : %0d",errors);

        $display("====================================================\n");

        $finish;

    end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:41:35
// Design Name: 
// Module Name: tap_controller
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



module tap_controller (
    input  wire       tck,
    input  wire       tms,
    input  wire       trst_n,          // Asynchronous active-low TAP reset
 
    output wire [3:0] tap_state,       // Current state (debug/observability)
 
    output wire       test_logic_reset,
    output wire       run_test_idle,
    output wire       select_dr_scan,
    output wire       capture_dr,
    output wire       shift_dr,
    output wire       exit1_dr,
    output wire       pause_dr,
    output wire       exit2_dr,
    output wire       update_dr,
    output wire       select_ir_scan,
    output wire       capture_ir,
    output wire       shift_ir,
    output wire       exit1_ir,
    output wire       pause_ir,
    output wire       exit2_ir,
    output wire       update_ir
);
 
    // ---------------------------------------------------------------
    // State encoding (one-hot NOT used intentionally; binary encoding
    // keeps the design compact and readable for review purposes)
    // ---------------------------------------------------------------
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
 
    reg [3:0] state, next_state;
 
    // ---------------------------------------------------------------
    // Sequential state register: async reset to TEST_LOGIC_RESET
    // ---------------------------------------------------------------
    always @(posedge tck or negedge trst_n) begin
        if (!trst_n)
            state <= TEST_LOGIC_RESET;
        else
            state <= next_state;
    end
 
    // ---------------------------------------------------------------
    // Combinational next-state logic (exact IEEE 1149.1 state diagram)
    // ---------------------------------------------------------------
    always @(*) begin
        case (state)
            TEST_LOGIC_RESET : next_state = tms ? TEST_LOGIC_RESET : RUN_TEST_IDLE;
            RUN_TEST_IDLE    : next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
 
            SELECT_DR_SCAN   : next_state = tms ? SELECT_IR_SCAN   : CAPTURE_DR;
            CAPTURE_DR       : next_state = tms ? EXIT1_DR         : SHIFT_DR;
            SHIFT_DR         : next_state = tms ? EXIT1_DR         : SHIFT_DR;
            EXIT1_DR         : next_state = tms ? UPDATE_DR        : PAUSE_DR;
            PAUSE_DR         : next_state = tms ? EXIT2_DR         : PAUSE_DR;
            EXIT2_DR         : next_state = tms ? UPDATE_DR        : SHIFT_DR;
            UPDATE_DR        : next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
 
            SELECT_IR_SCAN   : next_state = tms ? TEST_LOGIC_RESET : CAPTURE_IR;
            CAPTURE_IR       : next_state = tms ? EXIT1_IR         : SHIFT_IR;
            SHIFT_IR         : next_state = tms ? EXIT1_IR         : SHIFT_IR;
            EXIT1_IR         : next_state = tms ? UPDATE_IR        : PAUSE_IR;
            PAUSE_IR         : next_state = tms ? EXIT2_IR         : PAUSE_IR;
            EXIT2_IR         : next_state = tms ? UPDATE_IR        : SHIFT_IR;
            UPDATE_IR        : next_state = tms ? SELECT_DR_SCAN   : RUN_TEST_IDLE;
 
            default          : next_state = TEST_LOGIC_RESET; // Safe recovery
        endcase
    end
 
    // ---------------------------------------------------------------
    // Moore output decode (combinational, one-hot decode of current state)
    // ---------------------------------------------------------------
    assign tap_state        = state;
    assign test_logic_reset = (state == TEST_LOGIC_RESET);
    assign run_test_idle    = (state == RUN_TEST_IDLE);
    assign select_dr_scan   = (state == SELECT_DR_SCAN);
    assign capture_dr       = (state == CAPTURE_DR);
    assign shift_dr         = (state == SHIFT_DR);
    assign exit1_dr         = (state == EXIT1_DR);
    assign pause_dr         = (state == PAUSE_DR);
    assign exit2_dr         = (state == EXIT2_DR);
    assign update_dr        = (state == UPDATE_DR);
    assign select_ir_scan   = (state == SELECT_IR_SCAN);
    assign capture_ir       = (state == CAPTURE_IR);
    assign shift_ir         = (state == SHIFT_IR);
    assign exit1_ir         = (state == EXIT1_IR);
    assign pause_ir         = (state == PAUSE_IR);
    assign exit2_ir         = (state == EXIT2_IR);
    assign update_ir        = (state == UPDATE_IR);
 
endmodule
 
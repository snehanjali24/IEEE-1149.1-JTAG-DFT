`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:22:41
// Design Name: 
// Module Name: jtag_top
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

module jtag_top #(
    parameter DUT_WIDTH   = 4,          // Multiplier operand width
    parameter IR_WIDTH    = 3,          // Instruction register width
    parameter NUM_BS_CELLS = 2*DUT_WIDTH + 2*DUT_WIDTH  // 4(A)+4(B)+8(Y)=16
) (
    // ---------------- JTAG Interface ----------------
    input  wire                    tck,
    input  wire                    tms,
    input  wire                    trst_n,
    input  wire                    tdi,
    output wire                    tdo,
 
    // ------------- Functional (mission mode) I/O -------------
    input  wire [DUT_WIDTH-1:0]    a_func,
    input  wire [DUT_WIDTH-1:0]    b_func,
    output wire [2*DUT_WIDTH-1:0]  y_func,
 
    // ------------- Debug / observability (not part of IEEE 1149.1) -------
    output wire [3:0]              dbg_tap_state,
    output wire [IR_WIDTH-1:0]     dbg_ir_out,
    output wire                    dbg_mode_extest
);
 
    // ---------------------------------------------------------------
    // TAP Controller
    // ---------------------------------------------------------------
    wire       test_logic_reset, run_test_idle, select_dr_scan, select_ir_scan;
    wire       capture_dr, shift_dr, exit1_dr, pause_dr, exit2_dr, update_dr;
    wire       capture_ir, shift_ir, exit1_ir, pause_ir, exit2_ir, update_ir;
    wire [3:0] tap_state;
 
    tap_controller u_tap (
        .tck              (tck),
        .tms              (tms),
        .trst_n           (trst_n),
        .tap_state        (tap_state),
        .test_logic_reset (test_logic_reset),
        .run_test_idle    (run_test_idle),
        .select_dr_scan   (select_dr_scan),
        .capture_dr       (capture_dr),
        .shift_dr         (shift_dr),
        .exit1_dr         (exit1_dr),
        .pause_dr         (pause_dr),
        .exit2_dr         (exit2_dr),
        .update_dr        (update_dr),
        .select_ir_scan   (select_ir_scan),
        .capture_ir       (capture_ir),
        .shift_ir         (shift_ir),
        .exit1_ir         (exit1_ir),
        .pause_ir         (pause_ir),
        .exit2_ir         (exit2_ir),
        .update_ir        (update_ir)
    );
 
    // ---------------------------------------------------------------
    // Instruction Register + Decoder
    // ---------------------------------------------------------------
    wire [IR_WIDTH-1:0] ir_out;
    wire                 ir_tdo;
 
    instruction_register #(.IR_WIDTH(IR_WIDTH)) u_ir (
        .tck        (tck),
        .trst_n     (trst_n),
        .capture_ir (capture_ir),
        .shift_ir   (shift_ir),
        .update_ir  (update_ir),
        .tdi        (tdi),
        .tdo        (ir_tdo),
        .ir_out     (ir_out)
    );
 
    wire mode_extest, sample_preload_sel, bypass_sel;
 
    instruction_decoder #(.IR_WIDTH(IR_WIDTH)) u_decoder (
        .ir_out             (ir_out),
        .mode_extest        (mode_extest),
        .sample_preload_sel (sample_preload_sel),
        .bypass_sel         (bypass_sel)
    );
 
    // ---------------------------------------------------------------
    // Boundary Scan Register wrapping the multiplier DUT
    // ---------------------------------------------------------------
    wire [NUM_BS_CELLS-1:0] bsr_pi;   // Parallel inputs feeding the BSR cells
    wire [NUM_BS_CELLS-1:0] bsr_po;   // Parallel outputs driven by the BSR cells
    wire                     bsr_tdo;
 
    // DUT-side nets (after boundary scan input cells, before multiplier;
    // and DUT output, before boundary scan output cells)
    wire [DUT_WIDTH-1:0]     a_to_dut;
    wire [DUT_WIDTH-1:0]     b_to_dut;
    wire [2*DUT_WIDTH-1:0]   y_from_dut;
 
    // Cell map: [0:3]=A inputs, [4:7]=B inputs, [8:15]=Y outputs
    assign bsr_pi[3:0]                              = a_func;      // A input-cell PI  = functional pin
    assign bsr_pi[7:4]                              = b_func;      // B input-cell PI  = functional pin
    assign bsr_pi[8 +: 2*DUT_WIDTH]                  = y_from_dut;  // Y output-cell PI = DUT output
 
    assign a_to_dut   = bsr_po[3:0];                                // A input-cell PO  -> DUT input
    assign b_to_dut   = bsr_po[7:4];                                // B input-cell PO  -> DUT input
    assign y_func      = bsr_po[8 +: 2*DUT_WIDTH];                  // Y output-cell PO -> functional pin
 
    boundary_scan_register #(.NUM_CELLS(NUM_BS_CELLS)) u_bsr (
        .tck         (tck),
        .trst_n      (trst_n),
        .capture_dr  (capture_dr),
        .shift_dr    (shift_dr),
        .update_dr   (update_dr),
        .mode_extest (mode_extest),
        .tdi         (tdi),
        .tdo         (bsr_tdo),
        .pi          (bsr_pi),
        .po          (bsr_po)
    );
 
    // ---------------------------------------------------------------
    // Multiplier DUT
    // ---------------------------------------------------------------
    multiplier_4x4 #(.WIDTH(DUT_WIDTH)) u_dut (
        .a       (a_to_dut),
        .b       (b_to_dut),
        .product (y_from_dut)
    );
 
    // ---------------------------------------------------------------
    // Bypass Register
    // ---------------------------------------------------------------
    wire bypass_tdo;
 
    bypass_register u_bypass (
        .tck        (tck),
        .trst_n     (trst_n),
        .capture_dr (capture_dr),
        .shift_dr   (shift_dr),
        .tdi        (tdi),
        .tdo        (bypass_tdo)
    );
 
    // ---------------------------------------------------------------
    // TDO output mux
    //   Combinational select, registered on the falling edge of TCK to
    //   emulate real-silicon TDO update timing (see header comment).
    // ---------------------------------------------------------------
    wire tdo_mux_d;
 
    assign tdo_mux_d = shift_ir ? ir_tdo :
                       bypass_sel ? bypass_tdo :
                       bsr_tdo;
 
    reg tdo_reg;
    always @(negedge tck or negedge trst_n) begin
        if (!trst_n)
            tdo_reg <= 1'b0;
        else
            tdo_reg <= tdo_mux_d;
    end
 
    assign tdo = tdo_reg;
 
    // ---------------------------------------------------------------
    // Debug/observability outputs (not part of IEEE 1149.1 interface)
    // ---------------------------------------------------------------
    assign dbg_tap_state  = tap_state;
    assign dbg_ir_out     = ir_out;
    assign dbg_mode_extest = mode_extest;
 
endmodule


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 10:02:26
// Design Name: 
// Module Name: tb_jtag_top
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


module tb_jtag_top;
 
    localparam DUT_WIDTH = 4;
    localparam IR_WIDTH   = 3;
 
    reg  tck, tms, trst_n, tdi;
    wire tdo;
    reg  [DUT_WIDTH-1:0]   a_func, b_func;
    wire [2*DUT_WIDTH-1:0] y_func;
    wire [3:0] dbg_tap_state;
    wire [IR_WIDTH-1:0] dbg_ir_out;
    wire dbg_mode_extest;
 
    integer errors;
    integer i;
 
    localparam [IR_WIDTH-1:0] EXTEST         = 3'b000;
    localparam [IR_WIDTH-1:0] SAMPLE_PRELOAD = 3'b001;
    localparam [IR_WIDTH-1:0] BYPASS         = 3'b111;
 
    jtag_top #(.DUT_WIDTH(DUT_WIDTH), .IR_WIDTH(IR_WIDTH)) dut (
        .tck             (tck),
        .tms             (tms),
        .trst_n          (trst_n),
        .tdi             (tdi),
        .tdo             (tdo),
        .a_func          (a_func),
        .b_func          (b_func),
        .y_func          (y_func),
        .dbg_tap_state   (dbg_tap_state),
        .dbg_ir_out      (dbg_ir_out),
        .dbg_mode_extest (dbg_mode_extest)
    );
 
    initial tck = 0;
    always #5 tck = ~tck;
 
    task check(input cond, input [1023:0] msg);
        begin
            if (!cond) begin
                $display("FAIL: %0s at time %0t", msg, $time);
                errors = errors + 1;
            end
        end
    endtask
 
    // -----------------------------------------------------------------
    // Single TCK edge with a given TMS value
    // -----------------------------------------------------------------
    // NOTE: jtag_top registers TDO on the FALLING edge of TCK (see
    // 08_jtag_top.v header comment - this mirrors common industry practice
    // of updating TDO off the negative TCK edge for timing margin). This
    // task therefore advances through both the rising edge (where TAP state
    // / shift / capture / update actually happen) AND the following falling
    // edge (where TDO becomes valid for the *next* sample), so that any
    // `tdo` read immediately after calling tap_edge() is up to date.
    task tap_edge(input tms_val);
        begin
            tms = tms_val;
            @(posedge tck); #1;
            @(negedge tck); #1;
        end
    endtask
 
    // -----------------------------------------------------------------
    // Full Instruction Register scan, starting and ending at RUN_TEST_IDLE.
    // Instruction bits are driven LSB-first on TDI (standard convention).
    // -----------------------------------------------------------------
    task load_instruction(input [IR_WIDTH-1:0] instr);
        integer k;
        begin
            tap_edge(1); // RTI          -> Select-DR-Scan
            tap_edge(1); // Select-DR-Scan -> Select-IR-Scan
            tap_edge(0); // Select-IR-Scan -> Capture-IR
            tap_edge(0); // Capture-IR     -> Shift-IR
            for (k = 0; k < IR_WIDTH; k = k + 1) begin
                tdi = instr[k];
                tap_edge((k == IR_WIDTH-1) ? 1 : 0); // last bit exits to Exit1-IR
            end
            tap_edge(1); // Exit1-IR -> Update-IR
            tap_edge(0); // Update-IR -> RUN_TEST_IDLE
        end
    endtask
 
    // -----------------------------------------------------------------
    // Generic DR scan of `len` bits, starting/ending at RUN_TEST_IDLE.
    // tdo_out[k] = value sampled on TDO immediately BEFORE the k-th shift
    // edge (i.e. exactly what CaptureDR loaded, un-reversed - see
    // tb_boundary_scan_register.v for the timing derivation).
    // -----------------------------------------------------------------
    task dr_scan(input integer len, input [15:0] tdi_in, output reg [15:0] tdo_out);
        integer k;
        begin
            tdo_out = 16'h0000;
            tap_edge(1); // RTI            -> Select-DR-Scan
            tap_edge(0); // Select-DR-Scan -> Capture-DR
            tap_edge(0); // Capture-DR     -> Shift-DR
            for (k = 0; k < len; k = k + 1) begin
                tdo_out = {tdo_out[14:0], tdo};   // sample BEFORE this edge
                tdi = tdi_in[k];
                tap_edge((k == len-1) ? 1 : 0);    // last bit exits to Exit1-DR
            end
            tap_edge(1); // Exit1-DR -> Update-DR
            tap_edge(0); // Update-DR -> RUN_TEST_IDLE
        end
    endtask
 
    reg [15:0] scan_out;
    reg [15:0] reversed_pattern;
 
    // Bit-reverse helper (see tb_boundary_scan_register.v for why this is
    // needed to predict the final chain state after shifting N bits in)
    function [15:0] reverse16;
        input [15:0] value;
        integer b;
        begin
            for (b = 0; b < 16; b = b + 1)
                reverse16[b] = value[15-b];
        end
    endfunction
 
    initial begin
        $dumpfile("tb_jtag_top.vcd");
        $dumpvars(0, tb_jtag_top);
    end
 
    initial begin
        errors = 0;
        trst_n = 0; tms = 1; tdi = 0; a_func = 0; b_func = 0;
        @(negedge tck);
        trst_n = 1;
        #1;
 
        // ===============================================================
        // TEST 1: Post-reset default state must be BYPASS, functional
        // datapath must be fully transparent (mission mode) with TAP idle
        // ===============================================================
        check(dbg_ir_out == BYPASS, "reset: instruction should default to BYPASS");
        check(dbg_mode_extest == 1'b0, "reset: mode_extest should be 0 (not EXTEST)");
 
        tap_edge(0); // TLR -> RUN_TEST_IDLE
 
        a_func = 4'd7; b_func = 4'd6; #1;
        check(y_func == (7*6), "functional mode (post-reset/BYPASS): y_func should equal a_func*b_func");
 
        a_func = 4'd15; b_func = 4'd15; #1;
        check(y_func == (15*15), "functional mode: max*max corner case");
 
        a_func = 4'd0; b_func = 4'd9; #1;
        check(y_func == 0, "functional mode: zero operand corner case");
 
        // ===============================================================
        // TEST 2: SAMPLE/PRELOAD - functional path stays transparent while
        // JTAG non-intrusively samples the boundary
        // ===============================================================
        load_instruction(SAMPLE_PRELOAD);
        check(dbg_ir_out == SAMPLE_PRELOAD, "IR scan: instruction should be SAMPLE_PRELOAD");
        check(dbg_mode_extest == 1'b0, "SAMPLE_PRELOAD: mode_extest must be 0 (transparent)");
 
        a_func = 4'd5; b_func = 4'd3; #1;
        check(y_func == (5*3), "SAMPLE_PRELOAD: functional multiply must still work (transparent boundary)");
 
        // Capture the boundary: pi[15:8]=y_from_dut, pi[7:4]=b_func, pi[3:0]=a_func
        dr_scan(16, 16'h0000, scan_out);
        check(scan_out[3:0]   == a_func, "SAMPLE: captured A input cells should equal a_func");
        check(scan_out[7:4]   == b_func, "SAMPLE: captured B input cells should equal b_func");
        check(scan_out[15:8]  == (5*3),  "SAMPLE: captured Y output cells should equal actual product");
 
        // Functional path must remain undisturbed by the SAMPLE DR-scan
        check(y_func == (5*3), "SAMPLE_PRELOAD: functional output undisturbed after DR-scan");
 
        // ===============================================================
        // TEST 3: EXTEST - drive DUT inputs purely from the scan chain,
        // fully overriding the functional pins, and observe the result
        // purely through capture/scan-out (not through y_func, which now
        // shows a controlled/preloaded pattern instead of the raw core
        // value, per correct EXTEST semantics)
        // ===============================================================
        load_instruction(EXTEST);
        check(dbg_ir_out == EXTEST, "IR scan: instruction should be EXTEST");
        check(dbg_mode_extest == 1'b1, "EXTEST: mode_extest must be 1");
 
        // Drive functional pins to a DIFFERENT value than the scan-loaded
        // test vector, to prove EXTEST fully overrides / ignores them.
        a_func = 4'd15; b_func = 4'd15;
 
        // Desired final chain state (post scan-in + UpdateDR):
        //   A cells (bits 3:0) = 4'd6, B cells (bits 7:4) = 4'd9,
        //   Y cells (bits 15:8) = 8'd0 (controlled/safe output value)
        reversed_pattern = reverse16({8'd0, 4'd9, 4'd6});
        dr_scan(16, reversed_pattern, scan_out);
 
        check(dut.a_to_dut == 4'd6, "EXTEST: DUT input A should be driven by scan chain (6), not a_func(15)");
        check(dut.b_to_dut == 4'd9, "EXTEST: DUT input B should be driven by scan chain (9), not b_func(15)");
        #1;
        check(dut.y_from_dut == (6*9), "EXTEST: DUT should compute product of scanned-in operands (6*9=54)");
        check(y_func == 8'd0, "EXTEST: y_func pins should show the controlled/preloaded pattern (0), not the raw product");
 
        // Second DR-scan: CaptureDR now samples the DUT's real output (54)
        // into the Y output cells; read it back via TDO.
        dr_scan(16, 16'h0000, scan_out);
        check(scan_out[15:8] == (6*9), "EXTEST: captured/scanned-out Y should equal actual DUT product (54)");
 
        // ===============================================================
        // TEST 4: EXTEST corner case - operands 0 and 15
        // ===============================================================
        reversed_pattern = reverse16({8'd0, 4'd15, 4'd0});
        dr_scan(16, reversed_pattern, scan_out);
        #1;
        check(dut.y_from_dut == 0, "EXTEST corner: 0 * 15 = 0");
        dr_scan(16, 16'h0000, scan_out);
        check(scan_out[15:8] == 0, "EXTEST corner: scanned-out product should be 0");
 
        reversed_pattern = reverse16({8'd0, 4'd15, 4'd15});
        dr_scan(16, reversed_pattern, scan_out);
        #1;
        check(dut.y_from_dut == (15*15), "EXTEST corner: 15*15=225 (max value, no overflow)");
        dr_scan(16, 16'h0000, scan_out);
        check(scan_out[15:8] == (15*15), "EXTEST corner: scanned-out product should be 225");
 
        // ===============================================================
        // TEST 5: BYPASS - shortest path, functional mode must be restored
        // ===============================================================
        load_instruction(BYPASS);
        check(dbg_ir_out == BYPASS, "IR scan: instruction should be BYPASS");
        check(dbg_mode_extest == 1'b0, "BYPASS: mode_extest must be 0 (functional transparent)");
 
        a_func = 4'd8; b_func = 4'd8; #1;
        check(y_func == (8*8), "BYPASS: functional multiply must still work");
 
        // Verify 1-bit bypass shift latency through the TDO mux
        tap_edge(1); tap_edge(0); tap_edge(0); // -> Select-DR -> Capture-DR -> Shift-DR
        tdi = 1'b1; tap_edge(0); #1;
        check(tdo == 1'b1, "BYPASS: tdo should equal tdi(1) after 1 shift (1-bit latency)");
        tdi = 1'b0; tap_edge(0); #1;
        check(tdo == 1'b0, "BYPASS: tdo should equal tdi(0) after 1 shift");
        tdi = 1'b1; tap_edge(1); #1; // exit to Exit1-DR
        check(tdo == 1'b1, "BYPASS: tdo should equal tdi(1) after 1 shift (2nd)");
        tap_edge(1); tap_edge(0); // Update-DR -> RUN_TEST_IDLE
 
        // ===============================================================
        // TEST 6: Mid-operation asynchronous reset must force safe state
        // ===============================================================
        load_instruction(EXTEST);
        trst_n = 0; #1;
        check(dbg_ir_out == BYPASS, "async reset mid-EXTEST: instruction must revert to BYPASS");
        check(dbg_mode_extest == 1'b0, "async reset mid-EXTEST: mode_extest must clear to 0");
        trst_n = 1;
        tap_edge(0); // TLR -> RTI
 
        if (errors == 0)
            $display("TB_JTAG_TOP: ALL TESTS PASSED (functional, SAMPLE/PRELOAD, EXTEST, BYPASS, reset)");
        else
            $display("TB_JTAG_TOP: %0d TEST(S) FAILED", errors);
 
        $finish;
    end
 
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:19:48
// Design Name: 
// Module Name: instruction_register
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


module instruction_register #(
    parameter IR_WIDTH = 3
) (
    input  wire                  tck,
    input  wire                  trst_n,
    input  wire                  capture_ir,
    input  wire                  shift_ir,
    input  wire                  update_ir,
    input  wire                  tdi,
    output wire                  tdo,
    output reg  [IR_WIDTH-1:0]   ir_out     // Latched current instruction
);
 
    localparam [IR_WIDTH-1:0] IR_CAPTURE_PATTERN = {{(IR_WIDTH-1){1'b0}}, 1'b1}; // e.g. 3'b001
    localparam [IR_WIDTH-1:0] IR_BYPASS           = {IR_WIDTH{1'b1}};            // e.g. 3'b111 (mandatory)
 
    reg [IR_WIDTH-1:0] ir_shift;
 
    // -------------------------------------------------------------------
    // Shift register: Capture / Shift
    // -------------------------------------------------------------------
    always @(posedge tck or negedge trst_n) begin
        if (!trst_n) begin
            ir_shift <= IR_BYPASS;
        end else if (capture_ir) begin
            ir_shift <= IR_CAPTURE_PATTERN;
        end else if (shift_ir) begin
            // Shift MSB-in, LSB-out toward TDO (LSB is closest to TDO)
            ir_shift <= {tdi, ir_shift[IR_WIDTH-1:1]};
        end
    end
 
    assign tdo = ir_shift[0];
 
    // -------------------------------------------------------------------
    // Update register: latched instruction, forced to BYPASS on reset
    // -------------------------------------------------------------------
    always @(posedge tck or negedge trst_n) begin
        if (!trst_n) begin
            ir_out <= IR_BYPASS;
        end else if (update_ir) begin
            ir_out <= ir_shift;
        end
    end
 
endmodule

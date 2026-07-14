`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:20:55
// Design Name: 
// Module Name: instruction_decoder
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


module instruction_decoder #(
    parameter IR_WIDTH = 3
) (
    input  wire [IR_WIDTH-1:0] ir_out,
 
    output wire                mode_extest,        // 1 = EXTEST selected
    output wire                sample_preload_sel,  // 1 = SAMPLE/PRELOAD selected
    output wire                bypass_sel           // 1 = BYPASS (or reserved/undefined code) selected
);
 
    localparam [IR_WIDTH-1:0] EXTEST          = 3'b000;
    localparam [IR_WIDTH-1:0] SAMPLE_PRELOAD  = 3'b001;
    
 
    assign mode_extest        = (ir_out == EXTEST);
    assign sample_preload_sel = (ir_out == SAMPLE_PRELOAD);
 
    // Safety default: BYPASS instruction OR any reserved/undefined code
    assign bypass_sel         = ~(mode_extest | sample_preload_sel);
 
endmodule

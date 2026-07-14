`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:42:37
// Design Name: 
// Module Name: bypass_register
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


module bypass_register (
    input  wire tck,
    input  wire trst_n,
    input  wire capture_dr,
    input  wire shift_dr,
    input  wire tdi,
    output wire tdo
);
 
    reg bypass_ff;
 
    always @(posedge tck or negedge trst_n) begin
        if (!trst_n) begin
            bypass_ff <= 1'b0;
        end else if (capture_dr) begin
            bypass_ff <= 1'b0;      // Mandatory fixed capture value
        end else if (shift_dr) begin
            bypass_ff <= tdi;
        end
    end
 
    assign tdo = bypass_ff;
 
endmodule

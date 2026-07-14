`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:15:08
// Design Name: 
// Module Name: multiplier_4x4
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


module multiplier_4x4 #(
    parameter WIDTH = 4
) (
    input  wire [WIDTH-1:0]   a,        // Multiplicand
    input  wire [WIDTH-1:0]   b,        // Multiplier
    output wire [2*WIDTH-1:0] product   // Full-precision unsigned product
);
 
    // Single-line combinational multiply. Synthesis tools will map this to a
    // dedicated multiplier macro / DSP block or an array-multiplier structure
    // depending on target library, since '*' is a standard synthesizable
    // operator for unsigned operands in Verilog-2001.
    assign product = a * b;
 
endmodule

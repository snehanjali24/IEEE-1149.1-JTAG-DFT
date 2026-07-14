`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2026 09:17:09
// Design Name: 
// Module Name: boundary_scan_register
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


module boundary_scan_register #(
    parameter NUM_CELLS = 16
) (
    input  wire                  tck,
    input  wire                  trst_n,
    input  wire                  capture_dr,
    input  wire                  shift_dr,
    input  wire                  update_dr,
    input  wire                  mode_extest,
    input  wire                  tdi,             // Serial in  (from TDI or IR mux)
    output wire                  tdo,             // Serial out (to TDO mux)
    input  wire [NUM_CELLS-1:0]  pi,              // Parallel inputs to the chain
    output wire [NUM_CELLS-1:0]  po               // Parallel outputs of the chain
);
 
    // Internal scan-link wires connecting SO(i) -> SI(i+1)
    wire [NUM_CELLS:0] scan_link;
 
    assign scan_link[0]        = tdi;
    assign tdo                 = scan_link[NUM_CELLS];
 
    genvar i;
    generate
        for (i = 0; i < NUM_CELLS; i = i + 1) begin : bsc_chain
            boundary_scan_cell u_bsc (
                .tck         (tck),
                .trst_n      (trst_n),
                .capture_dr  (capture_dr),
                .shift_dr    (shift_dr),
                .update_dr   (update_dr),
                .mode_extest (mode_extest),
                .si          (scan_link[i]),
                .pi          (pi[i]),
                .so          (scan_link[i+1]),
                .po          (po[i])
            );
        end
    endgenerate
    endmodule
 

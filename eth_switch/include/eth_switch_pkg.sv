`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 08:13:17 PM
// Design Name: 
// Module Name: 
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


package eth_switch_pkg;
localparam NUM_OF_PORTS = 4;
localparam RXTX_DATA_SIZE = 32;
localparam RXTXCTRL_BITS_SIZE = 4;
localparam DATA_IN_SIZE = 8;
localparam SRC_MAC_LEN = 50;
localparam DST_MAC_LEN = 50;
localparam FULL_MAC_LEN = SRC_MAC_LEN + DST_MAC_LEN;
endpackage;

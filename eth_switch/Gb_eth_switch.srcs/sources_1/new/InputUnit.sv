`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 08:05:15 PM
// Design Name: 
// Module Name: InputUnit
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

import eth_switch_pkg

module InputUnit(
    input clk,
    input   reset_n,
    input   [DATA_IN_SIZE-1:0] in_data,
    input   logic rx_ctrl,
    input   logic mac_ack,
    input   logic out_port_from_mac,
    output  logic mac_req,
    output  [FULL_MAC_LEN-1:0] mac_address
    );
    
endmodule

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
localparam PACKET_LEN = 512;
localparam FIFO_DEPTH = 2048;
localparam DATA_IN_SIZE = 8;
localparam ADDR_BUFFER_DEPTH = 12;
localparam ADDR_LEN = DATA_IN_SIZE * (ADDR_BUFFER_DEPTH/2);
localparam FULL_ADDR_LEN = DATA_IN_SIZE * ADDR_BUFFER_DEPTH;
localparam NUM_OF_PORTS = 4;
localparam RXTX_DATA_SIZE = 32;
localparam RXTXCTRL_BITS_SIZE = 4;

localparam SRC_MAC_LEN = 50;
localparam DST_MAC_LEN = 50;
localparam FULL_MAC_LEN = SRC_MAC_LEN + DST_MAC_LEN;

typedef enum logic [2:0] {
        IDLE = 0,
        FCS_CHECK,
        CHECK_ERROR,
        MAC_LEARN,
        PARSE_ADDR,
        DELETE_PACKET
    } GLOBAL_STATE_t;
    
endpackage

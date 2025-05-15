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
localparam NUM_OF_PORTS_BITS = $clog2(NUM_OF_PORTS);
localparam RXTX_DATA_SIZE = 32;
localparam RXTXCTRL_BITS_SIZE = 4;

localparam SRC_MAC_LEN = 50;
localparam DST_MAC_LEN = 50;
localparam FULL_MAC_LEN = SRC_MAC_LEN + DST_MAC_LEN;

localparam TABLE_SIZE = 8000;
localparam TABLE_ADDR_WIDTH = 13;

typedef enum logic [3:0] {
        IDLE = 0,
        FCS_CHECK,
        CHECK_ERROR,
        MAC_LEARN,
        GET_LENGTH,
        OUT_SEND,
        PARSE_ADDR,
        DELETE_PACKET,
        OUT_SENDING
    } GLOBAL_STATE_t;
    
     typedef enum logic [3:0] {
        CHECK_P1,
        CHECK_P2,
        CHECK_P3,
        CHECK_P4,
        HASHING_SRC,
        HASHING_DEST,
        TABLE_PROCESSES,
        COMPARE_MAC,
        SEND_ACK
    } state_t;

    
    typedef struct packed {
        logic [47:0] mac;
        logic [3:0] port;
    } mac_table_entry_t;

     typedef enum logic [2:0] {
    PORT0  = 3'd0,
    PORT1  = 3'd1,
    PORT2  = 3'd2,
    PORT3   = 3'd3,
    ALL_PORTS= 3'd7,
    NONE_PORT   = 3'd5
 } PORT_t;
    
 typedef enum logic {
        P_IDLE=0,
        P_ACTIVE=1
 } P_STATUS;
 typedef struct packed{    
      P_STATUS target_port;
      PORT_t   pair;
 } SW_PORT_STATUS;
 
     typedef enum logic [2:0] {
        PACKET_SENT = 0,
        PACKET_RECEIVED  = 1,
        PACKET_FILLING =2,
        PACKET_SENDING = 3,
        PACKET_EMPTY    =4
    } BUFFER_STATUS_t;

 typedef logic [DATA_IN_SIZE-1:0] FLIT_t;
 typedef struct packed {
    FLIT_t flit;
    PORT_t target_port;
 } sw_bus_t;
 
 typedef enum logic [1:0] {
    OUT_IDLE = 0,
    OUT_ACTIVE = 1
    
 } OUT_STATE_t;
 
endpackage

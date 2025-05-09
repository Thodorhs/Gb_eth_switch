`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 06:19:57 PM
// Design Name: 
// Module Name: inputFSM
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

import eth_switch_pkg::*;

module inputFSM(
    input clk,
    input reset_n,
    input logic SOF,
    input logic EOF,
    input logic fcs_error,
    input logic i_addr_ack,
    input logic [ADDR_LEN-1:0] i_src_addr,
    input logic [ADDR_LEN-1:0] i_dst_addr,
    output logic fetch_en,
    output logic o_addr_req,
    output logic [ADDR_LEN-1:0] o_src_addr,
    output logic [ADDR_LEN-1:0] o_dst_addr,
    output logic o_mac_req
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    logic activate_mac = 0;
    
    always_comb begin
         next_state = IDLE;
         unique case(curr_state)
                IDLE : next_state = SOF == 1 ? FCS_CHECK : IDLE;
                FCS_CHECK:   next_state = (EOF == 1) ? (fcs_error == 0 ? PARSE_ADDR : DELETE_PACKET) : FCS_CHECK;
                PARSE_ADDR : next_state = activate_mac == 1 ? MAC_LEARN : PARSE_ADDR;
                MAC_LEARN : next_state = IDLE;
                DELETE_PACKET : next_state = IDLE;
                default : ;
         endcase 
    end
    
    always_comb begin
    activate_mac <= 0;
    case(curr_state)
                IDLE : begin
                    fetch_en <= 0;
                    o_mac_req <= 0;
                    o_src_addr <= 0;
                    o_dst_addr <= 0;
                    activate_mac <= 0;
                end
                FCS_CHECK : begin
                    
                end
                PARSE_ADDR : begin
                    o_addr_req <= 1;
                    if (i_addr_ack)
                        activate_mac <= 1;
                        
                end
                MAC_LEARN : begin
                    o_src_addr <= i_src_addr;
                    o_dst_addr <= i_dst_addr;
                    o_mac_req <= 1;
                    o_addr_req <= 0;
                end
                DELETE_PACKET : begin //delete packet and metadata from ALL FIFOS!
                    
                end
         endcase
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
        
    end
endmodule

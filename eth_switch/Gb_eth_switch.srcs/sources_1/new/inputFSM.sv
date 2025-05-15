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

module inputFSM#(
    parameter int PORT_NUM = 0  // Unique ID for this port instance
)(
    input clk,
    input reset_n,
    input logic SOF,
    input logic EOF,
    input logic fcs_error,
    input logic i_addr_ack,
    input logic [ADDR_LEN-1:0] i_src_addr,
    input logic [ADDR_LEN-1:0] i_dst_addr,
    input logic [11:0] input_length,
    input logic length_ack,
    input logic mac_ack,
    input logic [3:0]d_port_from_mac,
    output logic [3:0]s_port_for_mac,
    output logic fetch_en,
    output logic o_addr_req,
    output logic [95:0] o_mac_addr,
    
    output logic o_mac_req,
    output logic length_req,
    output PORT_t o_target_port,
    output logic o_switch_req,
    input logic i_switch_ack,
    output logic [NUM_OF_PORTS-1:0] o_packet_done
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    logic [11:0]curr_length='0;
    logic [11:0]curr_length_ff;
    logic activate_mac = 0;
    logic activate_send = 0;
    logic activate_length = 0;
  
    PORT_t target_port;
      assign o_target_port = target_port;
    always_comb begin
         next_state = IDLE;
         fetch_en = 0;
         o_packet_done = '0;

         unique case(curr_state)
                IDLE : next_state = SOF == 1 ? FCS_CHECK : IDLE;
                FCS_CHECK:   next_state = (EOF == 1) ? (fcs_error == 0 ? PARSE_ADDR : DELETE_PACKET) : FCS_CHECK;
                PARSE_ADDR : next_state = activate_mac == 1 ? MAC_LEARN : PARSE_ADDR;
                MAC_LEARN : next_state = activate_length == 1 ? GET_LENGTH : MAC_LEARN;
                GET_LENGTH : next_state = activate_send == 1 ? OUT_SEND: GET_LENGTH;
                OUT_SEND : next_state = i_switch_ack ? OUT_SENDING : OUT_SEND;
                OUT_SENDING : begin
                     next_state = $signed(curr_length) > 0 ? OUT_SENDING : IDLE;
                       if($signed(curr_length) > 0) begin
                         fetch_en = 1;
                    end
                    else begin
                        fetch_en = 0;
                        if(target_port == ALL_PORTS) o_packet_done = '1;
                        else o_packet_done[target_port] = 1;
                    end
                  end
                DELETE_PACKET : next_state = IDLE;
                default : ;
         endcase 
    end
    
    always_comb begin
    activate_mac = 0;
    activate_send = 0;
    o_mac_req = 0;
    o_mac_addr = '0;
    activate_length = 0;
    o_switch_req = 0;
    case(curr_state)
                IDLE : begin
//                    fetch_en = 0;
                    o_mac_req = 0;
                    o_mac_addr = '0;
                    activate_mac = 0;
                    activate_send = 0;
                    activate_length = 0;
                end
                FCS_CHECK : begin
                    
                end
                PARSE_ADDR : begin
                    o_addr_req = 1;
                    if (i_addr_ack)
                        activate_mac = 1;
                        
                end
                MAC_LEARN : begin
                    if (mac_ack) begin
                        activate_length = 1;
                        o_addr_req = 0;
                        o_mac_req = 0;
                    end else begin
                        activate_length = 0;
                        s_port_for_mac = PORT_NUM[3:0];
                        o_mac_addr = {i_src_addr, i_dst_addr};
                        o_mac_req = 1;
                    end
                end
                GET_LENGTH : begin
                    length_req = 1;
                    if(length_ack) begin
                        curr_length = input_length;
                        activate_send = 1;
                    end                    
                end
                OUT_SEND : begin
                    length_req = 0; 
                    o_switch_req = 1;  
                           
                end
                OUT_SENDING : begin 
                    
                  
                    curr_length = $unsigned(curr_length_ff) - 1;
                    
                end
                DELETE_PACKET : begin //delete packet and metadata from ALL FIFOS!
                    
                end
         endcase
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            curr_state <= IDLE;
            curr_length_ff <= '0;
            target_port <= NONE_PORT;
        end
        else begin
            curr_state <= next_state;
            curr_length_ff <= curr_length;
            if (mac_ack) target_port <= PORT_t'(d_port_from_mac);
            if(curr_state == IDLE) target_port <= NONE_PORT;
        end
        
    end
endmodule

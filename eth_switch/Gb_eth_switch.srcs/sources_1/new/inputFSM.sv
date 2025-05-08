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
    output logic fetch_en
    );
    
    GLOBAL_STATE_t curr_state;
    GLOBAL_STATE_t next_state;
    
    always_comb begin
         next_state = IDLE;
         unique case(curr_state)
                IDLE : next_state = SOF == 1 ? FCS_CHECK : IDLE;
                FCS_CHECK : next_state = EOF == 1 ? CHECK_ERROR : FCS_CHECK;
                CHECK_ERROR : next_state = fcs_error == 1 ? DELETE_PACKET : PARSE_ADDR;
                PARSE_ADDR : next_state = IDLE;
                DELETE_PACKET : next_state = IDLE;
                default : ;
         endcase 
    end
    
    always_comb begin
    case(curr_state)
                IDLE : begin
                    fetch_en = 0;
                end
                FCS_CHECK : begin
                    
                end
                CHECK_ERROR : begin
                 
                end
                PARSE_ADDR : begin
                    
                end
                DELETE_PACKET : begin 
                  
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

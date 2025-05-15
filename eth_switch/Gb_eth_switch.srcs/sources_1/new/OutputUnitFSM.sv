`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.03.2025 14:11:27
// Design Name: 
// Module Name: OutputUnitFSM
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


module OutputUnitFSM
    import eth_switch_pkg::*;

    (
    input clk,
    input reset_n,
    input FLIT_t i_flit[NUM_OF_PORTS],
    input logic  i_switch_req [NUM_OF_PORTS],
    output logic o_outport_ack [NUM_OF_PORTS],
    output P_STATUS o_port_status,
    input i_packet_done [NUM_OF_PORTS],
    output FLIT_t o_flit,
    output logic o_tx_ctrl
    );
    
    OUT_STATE_t curr_state;
    OUT_STATE_t next_state;
    logic send_done;
    logic [$clog2(NUM_OF_PORTS)-1:0] requesting_port;
    logic found_port;
    logic [NUM_OF_PORTS-1:0] requesting_port_ff;
    logic [NUM_OF_PORTS-1:0] req_idx;
    logic [NUM_OF_PORTS-1:0] grant;
    logic [NUM_OF_PORTS-1:0] request;
    
    arbiter arb (
        .clk(clk),
        .rst_n(reset_n),
        .req(request),
        .grant(grant)   
    );
    
    always_comb begin
        next_state = OUT_IDLE;
        found_port = 0;
        req_idx = '0;
        request = '0;
        if(curr_state == OUT_IDLE) begin
            for (int i = 0; i < NUM_OF_PORTS; i++) begin
                request[i] = i_switch_req[i]; 
            end
            
        end
        
        casez (grant)
           4'b???1: req_idx = 2'd0;
           4'b??10: req_idx = 2'd1;
           4'b?100: req_idx = 2'd2;
           4'b1000: req_idx = 2'd3;
           default: req_idx = 2'd0;  
       endcase
        
         unique case(curr_state)
                OUT_IDLE : next_state    = |grant ? OUT_ACTIVE : OUT_IDLE;
                OUT_ACTIVE : next_state  = send_done ? OUT_IDLE : OUT_ACTIVE;
                default : ;
         endcase 
    end
       assign o_port_status = curr_state == OUT_IDLE ? P_IDLE : P_ACTIVE;
       always_comb begin
         o_outport_ack = '{default:0};
         send_done = 0;
         requesting_port = requesting_port_ff;
         o_tx_ctrl = 0;
         o_flit = '0;
         case(curr_state)
                OUT_IDLE : begin
                 requesting_port = req_idx;
                   
                end
             
                OUT_ACTIVE : begin
                    o_outport_ack[requesting_port] = 1;
                    o_tx_ctrl = 1;
                    o_flit = i_flit[requesting_port];
                   if(i_packet_done[requesting_port]) begin
                      o_outport_ack[requesting_port] = 0;
                      send_done = 1;
                      o_tx_ctrl = 0;
                   end
                end
         endcase 
    
    end
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n) begin
            curr_state <= OUT_IDLE;
            requesting_port_ff <= '0;
        end
        else begin
            requesting_port_ff <= requesting_port;
            curr_state <= next_state;
        end
    end
endmodule

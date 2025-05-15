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
    input FLIT_t i_flit,
    input logic  i_switch_req [NUM_OF_PORTS],
    output logic o_outport_ack [NUM_OF_PORTS],
    output P_STATUS o_port_status
    );
    
    OUT_STATE_t curr_state;
    OUT_STATE_t next_state;
    logic send_done;
    logic [$clog2(NUM_OF_PORTS)-1:0] requesting_port;
    logic found_port;
    logic [NUM_OF_PORTS-1:0] requesting_port_ff;
    logic [NUM_OF_PORTS-1:0] req_idx;
    always_comb begin
        next_state = OUT_IDLE;
        found_port = 0;
        req_idx = '0;
        for (int i = 0; i < NUM_OF_PORTS; i++) begin
            if (i_switch_req[i] && curr_state == OUT_IDLE) begin
                //requesting_port = i;
                req_idx = i;
                found_port = 1;
                break;
            end
        end
         unique case(curr_state)
                OUT_IDLE : next_state    = found_port ? OUT_ACTIVE : OUT_IDLE;
                OUT_ACTIVE : next_state  = send_done ? OUT_IDLE : OUT_ACTIVE;
                default : ;
         endcase 
    end
       assign o_port_status = curr_state == OUT_IDLE ? P_IDLE : P_ACTIVE;
       always_comb begin
         o_outport_ack = '{default:0};
         send_done = 0;
         requesting_port = requesting_port_ff;
         case(curr_state)
                OUT_IDLE : begin
                  requesting_port = req_idx;
                end
             
                OUT_ACTIVE : begin
                    o_outport_ack = '{default:1};
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

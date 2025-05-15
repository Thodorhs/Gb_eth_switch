`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2025 18:17:43
// Design Name: 
// Module Name: OutputUnit
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


module OutputUnit
    import eth_switch_pkg::*;

    (
    input   clk,
    input   reset_n,
    input   FLIT_t i_flit [NUM_OF_PORTS],
    input   logic  i_cross_request [NUM_OF_PORTS],
    output  logic o_cross_ack [NUM_OF_PORTS],
    output  P_STATUS o_port_status
    );
     
    logic switch_ack_ff;
    OutputUnitFSM ofsm (
        .clk(clk),
        .reset_n(reset_n),
        .i_flit(i_flit[0]),
        .i_switch_req(i_cross_request),
        .o_outport_ack(o_cross_ack),
        .o_port_status(o_port_status)
        
    );
    
    
//      always_ff@(posedge clk, negedge reset_n) begin : switch_ack_reg
//        if(~reset_n)
//            o_outport_ack <= '0;
//        else
//            o_outport_ack <= switch_ack;
      
//    end
    
//    always_ff@(posedge clk, negedge reset_n) begin : switch_2_downstream
//        if(~reset_n) begin
//            o_o2d.flit <=  invalid_flit();
//            o_o2d.target_port <= NONE_PORT;
//        end
//        else begin 
//            o_o2d.flit <= s2d.flit;
            
//        end       
//    end
    
endmodule

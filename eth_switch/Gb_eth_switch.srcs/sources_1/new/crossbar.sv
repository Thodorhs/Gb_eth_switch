`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/10/2025 03:31:49 PM
// Design Name: 
// Module Name: Switch
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

module crossbar
    #(parameter unsigned PORT_NUM ) (
        input clk,
        input rst_n,
        input  sw_bus_t i_r2s,
        input  logic i_switch_req,
        input  logic  i_out_ack [NUM_OF_PORTS:0],
        input logic [NUM_OF_PORTS-1:0] i_packet_done,
        output logic o_switch_ack,
        output logic  o_out_req[NUM_OF_PORTS:0],
        output FLIT_t o_switch_data [NUM_OF_PORTS]
    );
    integer i,j,k,x;
    SW_PORT_STATUS  [NUM_OF_PORTS-1:0] port_status;
    SW_PORT_STATUS [NUM_OF_PORTS-1:0] port_status_ff;
    logic [NUM_OF_PORTS-1:0] cross_fifo_read = '0 ;
    logic [NUM_OF_PORTS-1:0] cross_fifo_write = '0;
    logic [NUM_OF_PORTS-1:0] cross_fifo_full ='0;
    logic [NUM_OF_PORTS-1:0] cross_fifo_empty = '0;
    
    BUFFER_STATUS_t [NUM_OF_PORTS-1:0] next_fifo_status = '{default: PACKET_EMPTY};
    BUFFER_STATUS_t [NUM_OF_PORTS-1:0] curr_fifo_status = '{default: PACKET_EMPTY};
    
    
   sfifo #(DATA_IN_SIZE,$clog2(FIFO_DEPTH)) cross_fifo0 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_fifo_write(cross_fifo_write[0]),
                    .i_fifo_read(cross_fifo_read[0]),
                    .i_fifo_write_data(i_r2s.flit),
                    .o_fifo_full(cross_fifo_full[0]),
                    .o_fifo_read_data(o_switch_data[0]),
                    .o_fifo_empty(cross_fifo_empty[0])
                );
    
    sfifo #(DATA_IN_SIZE,$clog2(FIFO_DEPTH)) cross_fifo1 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_fifo_write(cross_fifo_write[1]),
                    .i_fifo_read(cross_fifo_read[1]),
                    .i_fifo_write_data(i_r2s.flit),
                    .o_fifo_full(cross_fifo_full[1]),
                    .o_fifo_read_data(o_switch_data[1]),
                    .o_fifo_empty(cross_fifo_empty[1])
                );
    
    sfifo #(DATA_IN_SIZE,$clog2(FIFO_DEPTH)) cross_fifo2 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_fifo_write(cross_fifo_write[2]),
                    .i_fifo_read(cross_fifo_read[2]),
                    .i_fifo_write_data(i_r2s.flit),
                    .o_fifo_full(cross_fifo_full[2]),
                    .o_fifo_read_data(o_switch_data[2]),
                    .o_fifo_empty(cross_fifo_empty[2])
                );
    sfifo #(DATA_IN_SIZE,$clog2(FIFO_DEPTH)) cross_fifo3 (
                    .clk(clk),
                    .rst_n(rst_n),
                    .i_fifo_write(cross_fifo_write[3]),
                    .i_fifo_read(cross_fifo_read[3]),
                    .i_fifo_write_data(i_r2s.flit),
                    .o_fifo_full(cross_fifo_full[3]),
                    .o_fifo_read_data(o_switch_data[3]),
                    .o_fifo_empty(cross_fifo_empty[3])
                );
 

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            curr_fifo_status <= '{default: PACKET_EMPTY};
        end
        else begin
            curr_fifo_status <= next_fifo_status;
        end
   end
       

    always_comb begin
        next_fifo_status = curr_fifo_status;
        o_switch_ack = 0;
        o_out_req = '{default:0};
        cross_fifo_write = '{default: 0};
        cross_fifo_read = '{default: 0};
        
        for(i=0; i < NUM_OF_PORTS; i++) begin
              if(next_fifo_status[i] == PACKET_FILLING) begin 
                    cross_fifo_write[i] = 1'b1;
                end
                
              if( curr_fifo_status[i] == PACKET_FILLING && i_packet_done[i]) 
                next_fifo_status[i] = PACKET_RECEIVED;
                
              if(curr_fifo_status[i] == PACKET_RECEIVED) 
                 o_out_req[i] = 1;
                 
              if(curr_fifo_status[i] == PACKET_SENDING)
                    cross_fifo_read[i] = 1;
              
              if(curr_fifo_status[i] == PACKET_RECEIVED && i_out_ack[i]) 
                next_fifo_status[i] = PACKET_SENDING;
                
              if(curr_fifo_status[i] == PACKET_SENDING && cross_fifo_empty[i]) begin
                cross_fifo_read[i] = 0;
                next_fifo_status[i] = PACKET_EMPTY;
              end
       
        end
        
      
       
        if(i_switch_req && i_r2s.target_port != NONE_PORT) begin
            if(i_r2s.target_port == ALL_PORTS) begin
                if(curr_fifo_status[0] == PACKET_EMPTY &&
                   curr_fifo_status[1] == PACKET_EMPTY &&
                   curr_fifo_status[2] == PACKET_EMPTY &&
                   curr_fifo_status[3] == PACKET_EMPTY) begin
                   
                    next_fifo_status[0] = PACKET_FILLING;
                    next_fifo_status[1] = PACKET_FILLING;
                    next_fifo_status[2] = PACKET_FILLING;
                    next_fifo_status[3] = PACKET_FILLING;
                    o_switch_ack = 1;
                   
                end 
            end
            else if( curr_fifo_status[i_r2s.target_port] == PACKET_EMPTY) begin
                next_fifo_status[i_r2s.target_port] = PACKET_FILLING;
                o_switch_ack = 1;
            end
        end
   
        end
    
   

//   logic [4:0] grant;
//   logic [4:0] request_en;
//   integer y;
//   always_comb begin
//    request_en = '0;
    
//        if(i_switch_req) begin
//            if(i_r2s.target_port != NONE_PORT) begin
//                request_en = i_oport[i_r2s.target_port] == P_IDLE ? 5'b1 << i_r2s.target_port : '0;
//            end
//        end
        
    
//   end
   
//   arbiter arb (
//    .clk(clk),
//    .rst_n(rst_n),
//    .req(request_en),
//    .grant(grant)
//   );
    
//   always_comb begin
//    o_outport_req = '{default: 0};
//    routing_success = '{default: 0};
//    port_status = port_status_ff;
 
//    for(i=0; i<NUM_OF_PORTS; i=i+1) begin 
//         o_outport_req[i_r2s[i].target_port][i] = (request_en[i] && grant[i]) ? 1  :'0;
//    end

//    for(x=0; x<NUM_OF_PORTS; x=x+1) begin
          
//          if (i_outport_ack[i_r2s[x].target_port][x] && port_status[i_r2s[x].target_port].target_port == P_IDLE ) begin
//            routing_success[x] = 1'b1;    
//            port_status[i_r2s[x].target_port].target_port = P_ACTIVE;
//            port_status[i_r2s[x].target_port].pair = PORT_t'(x);
//          end 
//    end
//   end
//    integer y,l;
  
//  always_ff @(posedge clk, negedge rst_n) begin
//    if(~rst_n) begin
//        o_s2o <= '{default: 0};
//         for(y=0; y<NUM_OF_PORTS; y=y+1) begin
//            port_status_ff[y].target_port <=  P_IDLE;
//            port_status_ff[y].pair <= NONE_PORT;
//         end
      
//    end
//    else    begin 
//        port_status_ff <= port_status;
     
//        for(l=0; l<NUM_OF_PORTS; l=l+1) begin
//         if(i_r2s[l].flit.tail.flit_type == TAIL_FLIT) begin
//            port_status_ff[i_r2s[l].target_port].target_port <= P_IDLE;
//            port_status_ff[i_r2s[l].target_port].pair <= NONE_PORT;
//          end
          
//          if(port_status[l].target_port == P_ACTIVE) begin
//            o_s2o[l] <= i_r2s[port_status[l].pair];
//          end
//          else o_s2o[l] <= invalid_flit();
//        end
//  end
// end
endmodule

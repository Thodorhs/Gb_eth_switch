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

import eth_switch_pkg::*;

module InputUnit#(
    parameter int PORT_NUM = 0  // Unique ID for this port instance
)(
    input clk,
    input   reset_n,
    input   [DATA_IN_SIZE-1:0] in_data,
    input   logic rx_ctrl,
    input   logic mac_ack,
    input  logic [3:0]d_port_from_mac,
    output   logic [3:0]s_port_for_mac,
    output  [DATA_IN_SIZE-1:0] out_data,
    output  logic mac_req,
    output  [95:0] mac_address,
    output sw_bus_t o_r2s,
    output logic o_switch_req,
    input logic i_switch_ack,
    output logic [NUM_OF_PORTS-1:0] o_packet_done
    );
    
    logic [DATA_IN_SIZE-1:0] data_ff;
    logic buffer_write;
    logic fetch_en = 0;
    logic buffer_full;
    logic buffer_empty;
    logic [DATA_IN_SIZE-1:0] buffer_odata;
    logic SOF;
    logic EOF;
    logic fcs_error_flag;
    logic length_req=0;
    logic [11:0]length_out = '0;
    logic length_ack=0;
    
    assign o_r2s.flit = buffer_odata;
    // address buffer
    logic addr_req=0;
    logic addr_ack=0;
    logic [ADDR_LEN-1:0] src_addr='0;
    logic [ADDR_LEN-1:0] dst_addr='0;
    
     sfifo #(DATA_IN_SIZE,$clog2(FIFO_DEPTH)) INPUT_BUFFER 
    (
      .clk(clk),
      .rst_n(reset_n),
      .i_fifo_write(buffer_write),
      .i_fifo_read(fetch_en),
      .i_fifo_write_data(data_ff),
      .o_fifo_full(buffer_full),
      .o_fifo_read_data(buffer_odata),
      .o_fifo_empty(buffer_empty)
    );
    
    addr_buffer addr_buffer_handle(
        .clk(clk),
        .reset_n(reset_n),
        .data_in(data_ff),
        .rx_ctrl(rx_ctrl),
        .addr_req(addr_req),
        .addr_ack(addr_ack),
        .src_addr(src_addr),
        .dst_addr(dst_addr)
    );
    
    length_count length_counter(
        .clk(clk),
        .reset_n(reset_n),
        .rx_ctrl(rx_ctrl),
        .EOF(EOF),
        .length_ack(length_ack),
        .length_req(length_req),
        .length_out(length_out)
    );
    
    inputFSM #(
            .PORT_NUM(PORT_NUM)
        )inFSM(
      .clk(clk),
      .reset_n(reset_n),
      .fetch_en(fetch_en),
      .SOF(SOF),
      .EOF(EOF),
      .fcs_error(fcs_error_flag),
      .o_addr_req(addr_req),
      .i_addr_ack(addr_ack),
      .i_src_addr(src_addr),
      .i_dst_addr(dst_addr),
      .d_port_from_mac(d_port_from_mac),
      .s_port_for_mac(s_port_for_mac),
      .o_mac_addr(mac_address),
      .o_mac_req(mac_req),
      .length_req(length_req),
      .length_ack(length_ack),
      .mac_ack(mac_ack),
      .input_length(length_out),
      .o_target_port(o_r2s.target_port),
      .o_switch_req(o_switch_req),
      .i_switch_ack(i_switch_ack),
      .o_packet_done(o_packet_done)
    );
    
    SOF_EOF_ctrl SOF_EOF_ctrl_inst(
      .clk(clk),
      .reset_n(reset_n),
      .rx_ctrl(rx_ctrl),
      .SOF(SOF),
      .EOF(EOF)
    );
    
    fcs_check_parallel fcs_inst (
        .clk(clk),
        .reset(~reset_n), // Assuming reset_n is active-low in SV, and VHDL uses active-high
        .start_of_frame(SOF), 
        .fcs_rx_ctrl(rx_ctrl),   
        .data_in(data_ff[7:0]),
        .fcs_error(fcs_error_flag)
    );
    
    logic rx_ctrl_d;


always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        rx_ctrl_d <= 0;
        data_ff <= '0;
    end
    else begin
        rx_ctrl_d <= rx_ctrl;
        data_ff <= in_data;
    end
end

assign buffer_write = rx_ctrl_d;


    
    
endmodule

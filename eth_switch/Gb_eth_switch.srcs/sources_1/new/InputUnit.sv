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

module InputUnit(
    input clk,
    input   reset_n,
    input   [DATA_IN_SIZE-1:0] in_data,
    input   logic rx_ctrl,
    input   logic mac_ack,
    input   logic out_port_from_mac,
    output  [DATA_IN_SIZE-1:0] out_data,
    output  logic mac_req,
    output  [FULL_MAC_LEN-1:0] mac_address
    );
    
    logic buffer_write;
    logic fetch_en = 0;
    logic buffer_full;
    logic buffer_empty;
    logic [DATA_IN_SIZE-1:0] buffer_odata;
    logic SOF;
    logic EOF;
    logic fcs_error_flag;
    
    
     sfifo #(DATA_IN_SIZE,FIFO_DEPTH) INPUT_BUFFER 
    (
      .clk(clk),
      .rst_n(reset_n),
      .i_fifo_write(buffer_write),
      .i_fifo_read(fetch_en),
      .i_fifo_write_data(in_data),
      .o_fifo_full(buffer_full),
      .o_fifo_read_data(buffer_odata),
      .o_fifo_empty(buffer_empty)
    );
    
    inputFSM inFSM(
      .clk(clk),
      .reset_n(reset_n),
      .fetch_en(fetch_en),
      .SOF(SOF),
      .EOF(EOF),
      .fcs_error(fcs_error_flag)
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
        .data_in(in_data[7:0]),
        .fcs_error(fcs_error_flag)
    );
    
    always_ff @(posedge clk, negedge reset_n) begin
        if(~reset_n)
            buffer_write <= 0;
        else if (rx_ctrl)
            buffer_write <= 1;
        else
            buffer_write <= 0; 
    end
    
    
endmodule

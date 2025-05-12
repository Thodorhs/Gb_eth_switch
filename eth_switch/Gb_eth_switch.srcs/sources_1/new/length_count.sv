`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2025 08:35:10 PM
// Design Name: 
// Module Name: length_count
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
module length_count(
    input logic clk ,
    input  logic reset_n,
    input logic rx_ctrl,
    input logic EOF,
    input logic length_req,
    output logic length_ack,
    output logic [11:0]length_out
    );
    
    logic [11:0] byte_counter = '0;
    logic w_en=0;
    logic r_en = 0;
    logic buffer_full;
    logic buffer_empty;
    logic EOF_ff = 0;
    
    
    sfifo #(12,$clog2(4)) PACKET_LENGTH_FIFO 
    (
      .clk(clk),
      .rst_n(reset_n),
      .i_fifo_write(w_en),
      .i_fifo_read(r_en),
      .i_fifo_write_data(byte_counter),
      .o_fifo_full(buffer_full),
      .o_fifo_read_data(length_out),
      .o_fifo_empty(buffer_empty)
    );
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
             EOF_ff <= 0;
        end
        EOF_ff <= EOF;
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
             byte_counter <= 0;
        end
        if (rx_ctrl) begin
            byte_counter <= byte_counter + 1;
        end else if (EOF == 0 && EOF_ff == 1) begin
            byte_counter = 0;
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
             w_en <= 0;
        end
        if (EOF == 1) begin
            w_en <= 1;
        end else begin
            w_en <= 0;
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
             r_en <= 0;
             length_ack <=0;
        end
        if (length_req) begin
            r_en <= 1;
            length_ack <= 1;
        end else begin
            r_en <= 0;
            length_ack <=0;
        end
    end
    
endmodule

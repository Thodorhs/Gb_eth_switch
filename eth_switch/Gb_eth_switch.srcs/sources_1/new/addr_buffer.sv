`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2025 06:14:51 PM
// Design Name: 
// Module Name: addr_buffer
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
module addr_buffer(
    input logic clk ,
    input  logic reset_n,
    input  logic [DATA_IN_SIZE-1:0] data_in,
    input logic rx_ctrl,
    input logic addr_req,
    output logic addr_ack,
    output logic [ADDR_LEN-1:0] src_addr,
    output logic [ADDR_LEN-1:0] dst_addr
    );
    
    
    logic w_en=0;
    logic buffer_full;
    logic buffer_empty;
    logic [DATA_IN_SIZE-1:0] buffer_odata;
    logic [11:0] wr_add_counter = '0;
    
    logic r_en = 0;
    logic [ADDR_LEN-1:0] tmp_src = '0;
    logic [ADDR_LEN-1:0] tmp_dst = '0;
    logic [11:0] r_add_counter = '0;
    
    logic r_counter_en = 0;

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            r_counter_en <= 0;
        else if (addr_req)
            r_counter_en <= 1;
        else if (addr_ack)
            r_counter_en <= 0;
    end


    sfifo #(DATA_IN_SIZE,ADDR_BUFFER_DEPTH) ADDR_BUFFER 
    (
      .clk(clk),
      .rst_n(reset_n),
      .i_fifo_write(w_en),
      .i_fifo_read(r_en),
      .i_fifo_write_data(data_in),
      .o_fifo_full(buffer_full),
      .o_fifo_read_data(buffer_odata),
      .o_fifo_empty(buffer_empty)
    );
    
    

    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            w_en <= 0;
            wr_add_counter <= 0;
        end else begin
            if (rx_ctrl) begin
                if (wr_add_counter >= 7 && wr_add_counter < 19) begin
                    w_en <= 1;
                end else if (wr_add_counter == 19) begin
                    w_en <= 0;
                end else begin
                    w_en <= 0;
                end
                wr_add_counter <= wr_add_counter + 1;
            end else begin
                wr_add_counter <= 0;
                w_en <= 0;
            end
        end
    end
    
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            r_en <= 0;
            r_add_counter <= 0;
            tmp_src <= '0;
            tmp_dst <= '0;
            addr_ack <= 0;
            src_addr <= '0;
            dst_addr <= '0;
        end else begin
            if (addr_req ) begin
                r_en <= 1;
                addr_ack <= 0;
                if (r_counter_en) begin 
                    if (r_add_counter >= 0 && r_add_counter < ADDR_LEN) begin
                        r_en <= 1;
                        addr_ack <= 0;
                        tmp_dst[ADDR_LEN-1 - 8*r_add_counter -: 8] <= data_in;
                        r_add_counter <= r_add_counter + 1;
                    end else if (r_add_counter >= ADDR_LEN && r_add_counter < FULL_ADDR_LEN) begin
                        r_en <= 1;
                        addr_ack <= 0;
                        tmp_src[ADDR_LEN-1 - 8*r_add_counter -: 8] <= data_in;
                        r_add_counter <= r_add_counter + 1;
                    end else begin
                        r_en <= 1;
                        addr_ack <= 1;
                        src_addr <= tmp_src;
                        dst_addr <= tmp_dst;
                    end
                end 
            end else begin
                    r_en <= 0;
                    addr_ack <= 0;
                    r_add_counter <= 0;
                    tmp_src <= '0;
                    tmp_dst <= '0;
                end
        end
    end

    
    
endmodule

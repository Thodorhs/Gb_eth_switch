`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/02/2025 04:34:46 PM
// Design Name: 
// Module Name: Input_tb
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
`define CLK_PERIOD 10

module Input_tb();

    logic clk = 1;
    logic reset = 0;
    logic start = 0;
    logic [RXTX_DATA_SIZE-1:0] rx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] rx_ctrl_tb;
    logic [RXTX_DATA_SIZE-1:0] tx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] tx_ctrl_tb;
    
    always #(`CLK_PERIOD) clk = ~clk;
    
    eth_switch switch(
    .clk(clk),
    .reset_n(reset),
    .rx_data(rx_data_tb),
    .rx_ctrl(rx_ctrl_tb),
    .tx_data(tx_data_tb),
    .tx_ctrl(tx_ctrl_tb)
    );
    
    initial begin
        rx_data_tb = '0;
        rx_ctrl_tb = '0;

        repeat (2) @(posedge clk);
        reset = 1;
        @(posedge clk);

        send_packet(64); 
        
        repeat (100) @(posedge clk);
        $finish;
    end

   
    task send_packet(input int frame_size_bytes);
        int i;
        for (i = 0; i < frame_size_bytes; i += RXTX_DATA_SIZE/8) begin
            @(posedge clk);
            rx_data_tb = $random;        
            rx_ctrl_tb = 4'b0001;              
        end
        @(posedge clk);
        rx_ctrl_tb = '0;                
        rx_data_tb = '0;
    endtask
endmodule

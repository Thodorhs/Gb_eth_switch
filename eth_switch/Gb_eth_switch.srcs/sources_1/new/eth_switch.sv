`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2025 08:52:02 PM
// Design Name: 
// Module Name: eth_switch
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
module eth_switch(
    input   clk,
    input   reset_n,
    input   [RXTX_DATA_SIZE-1:0] rx_data,
    input   [RXTXCTRL_BITS_SIZE-1:0] rx_ctrl,
    output  [RXTX_DATA_SIZE-1:0] tx_data,
    output  [RXTXCTRL_BITS_SIZE-1:0] tx_ctrl
    );
    logic mac_ack[NUM_OF_PORTS];
    logic out_port_from_mac[NUM_OF_PORTS];
    logic mac_req[NUM_OF_PORTS];
    logic [FULL_MAC_LEN-1:0] mac_address[NUM_OF_PORTS];
    
    wire [DATA_IN_SIZE-1:0] rx_data_arr [0:NUM_OF_PORTS-1];
    
    genvar i;
    generate
        for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin : gen_assign
            assign rx_data_arr[i] = rx_data[(i+1)*DATA_IN_SIZE-1 -: DATA_IN_SIZE];
        end
    endgenerate


    genvar j;
    generate
        for (j = 0; j < NUM_OF_PORTS; j++) begin : gen_ports
            InputUnit in_inst 
            (
                .clk(clk),
                .reset_n(reset_n),
                .in_data(rx_data_arr[j]),
                .rx_ctrl(rx_ctrl[j]),
                .mac_ack(mac_ack[j]),
                .out_port_from_mac(out_port_from_mac[j]),
                .mac_req(mac_req[j]),
                .mac_address(mac_address[j])
            );   
        end
    endgenerate
endmodule

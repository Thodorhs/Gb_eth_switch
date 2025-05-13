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
    logic [3:0]s_port_for_mac[NUM_OF_PORTS];
    logic [3:0]d_port_from_mac[NUM_OF_PORTS];
    logic mac_req[NUM_OF_PORTS];
    logic [95:0] mac_address[NUM_OF_PORTS];
    
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
            InputUnit #(
            .PORT_NUM(j)
        )in_inst
            (
                .clk(clk),
                .reset_n(reset_n),
                .in_data(rx_data_arr[j]),
                .rx_ctrl(rx_ctrl[j]),
                .mac_ack(mac_ack[j]),
                .s_port_for_mac(s_port_for_mac[j]),
                .d_port_from_mac(d_port_from_mac[j]),
                .mac_req(mac_req[j]),
                .mac_address(mac_address[j])
            );   
        end
    endgenerate
    mac_learning_fsm mac_fsm_inst (
        .clk(clk),
        .reset(reset_n),

        .addresses_1(mac_address[0]),
        .s_port_1(s_port_for_mac[0]),
        .req_1(mac_req[0]),
        .ack_1(mac_ack[0]),
        .d_port_1(d_port_from_mac[0]),

        .addresses_2(mac_address[1]),
        .s_port_2(s_port_for_mac[1]),
        .req_2(mac_req[1]),
        .ack_2(mac_ack[1]),
        .d_port_2(d_port_from_mac[1]),

        .addresses_3(mac_address[2]),
        .s_port_3(s_port_for_mac[2]),
        .req_3(mac_req[2]),
        .ack_3(mac_ack[2]),
        .d_port_3(d_port_from_mac[2]),

        .addresses_4(mac_address[3]),
        .s_port_4(s_port_for_mac[3]),
        .req_4(mac_req[3]),
        .ack_4(mac_ack[3]),
        .d_port_4(d_port_from_mac[3])
    );
endmodule

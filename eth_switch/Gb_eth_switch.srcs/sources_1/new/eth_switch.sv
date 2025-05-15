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
    
    logic [NUM_OF_PORTS-1:0] switch_req,switch_ack;
    logic [NUM_OF_PORTS-1:0] packet_done [NUM_OF_PORTS];
    sw_bus_t r2s [NUM_OF_PORTS];
    wire [DATA_IN_SIZE-1:0] rx_data_arr [0:NUM_OF_PORTS-1];
    
    FLIT_t switch_data [NUM_OF_PORTS][NUM_OF_PORTS];
    FLIT_t switch_data2 [NUM_OF_PORTS][NUM_OF_PORTS];
    logic  out_ack [NUM_OF_PORTS][NUM_OF_PORTS];
    logic  out_req [NUM_OF_PORTS][NUM_OF_PORTS];
       logic  out_ack2 [NUM_OF_PORTS][NUM_OF_PORTS];
    logic  out_req2 [NUM_OF_PORTS][NUM_OF_PORTS];
    genvar i;
    generate
        for (i = 0; i < NUM_OF_PORTS; i = i + 1) begin : gen_assign
            assign rx_data_arr[i] = rx_data[(i+1)*DATA_IN_SIZE-1 -: DATA_IN_SIZE];
        end
    endgenerate
    
    genvar rows,cols;
    generate
        for(rows = 0; rows<NUM_OF_PORTS; rows++) begin
            for(cols = 0; cols<NUM_OF_PORTS; cols++) begin
                assign switch_data2[rows][cols] = switch_data[cols][rows]; 
                assign out_ack2[rows][cols] = out_ack[cols][rows];
                assign out_req2[rows][cols] = out_req[cols][rows];
            end
        
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
                .mac_address(mac_address[j]),
                .o_r2s(r2s[j]),
                .o_switch_req(switch_req[j]),
                .i_switch_ack(switch_ack[j]),
                .o_packet_done(packet_done[j])
            );   
            
            crossbar  #(
            .PORT_NUM(j)
            ) crossbar_inst (
                .clk(clk),
                .rst_n(reset_n),
                .i_r2s(r2s[j]),
                .i_switch_req(switch_req[j]),
                .i_out_ack(out_ack2[j]),
                .i_packet_done(packet_done[j]),
                .o_switch_ack(switch_ack[j]),
                .o_out_req(out_req2[j]),
                .o_switch_data(switch_data[j])  
            );
            
            OutputUnit out_inst(
                .clk(clk),
                .reset_n(reset_n),
                .i_flit(switch_data2[j]),
                .i_cross_request(out_req2[j]),
                .o_cross_ack(out_ack2[j])
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

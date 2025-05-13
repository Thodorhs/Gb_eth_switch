`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2025 02:32:36 AM
// Design Name: 
// Module Name: mac_tb
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
module mac_tb;

  logic clk;
  logic reset;

  // Port signals
  logic [95:0] addresses [4];
  logic [3:0]  s_ports     [4];
  logic        reqs        [4];
  logic        acks        [4];
  logic [3:0]  d_ports     [4];

  // Clock generation
  always #5 clk = ~clk;

  // Instantiate DUT
  mac_learning_fsm dut (
    .clk(clk),
    .reset(reset),
    .addresses_1(addresses[0]),
    .s_port_1(s_ports[0]),
    .req_1(reqs[0]),
    .ack_1(acks[0]),
    .d_port_1(d_ports[0]),

    .addresses_2(addresses[1]),
    .s_port_2(s_ports[1]),
    .req_2(reqs[1]),
    .ack_2(acks[1]),
    .d_port_2(d_ports[1]),

    .addresses_3(addresses[2]),
    .s_port_3(s_ports[2]),
    .req_3(reqs[2]),
    .ack_3(acks[2]),
    .d_port_3(d_ports[2]),

    .addresses_4(addresses[3]),
    .s_port_4(s_ports[3]),
    .req_4(reqs[3]),
    .ack_4(acks[3]),
    .d_port_4(d_ports[3])
  );

  logic [47:0] mac_a = 48'h001122334455;
  logic [47:0] mac_b = 48'h00AABBCCDDEE;
  logic [47:0] mac_c = 48'h000011112222;

  initial begin
    $display("Starting simulation...");
    clk = 0;
    reset = 0;
    reqs = '{default: 0};
    addresses = '{default: 0};
    s_ports = '{default: 0};

    #20;
    reset = 1;
    #20;

    
    s_ports[0] = 4'd1;
    addresses[0] = {mac_a, mac_b};  // src = A, dst = B
    reqs[0] = 1;

    wait (acks[0]);
    $display("T1: P1 Ack, d_port = %0d (expect 0xF==15) first src,dst MAC", d_ports[0]);
    reqs[0] = 0;

  
    repeat (2) @(posedge clk);
    s_ports[1] = 4'd2;
    addresses[1] = {mac_b, mac_a};  // src = B, dst = A
    reqs[1] = 1;

    wait (acks[1]);
    $display("T2: P2 Ack, d_port = %0d", d_ports[1]);
    reqs[1] = 0;

    
    repeat (2) @(posedge clk);
    s_ports[2] = 4'd3;
    addresses[2] = {mac_a, mac_c};  // src = A, dst = C (C not learned yet)
    reqs[2] = 1;

    wait (acks[2]);
    $display("T3: P3 Ack, d_port = %0d (expect 0xF==15)", d_ports[2]);
    reqs[2] = 0;

    repeat (2) @(posedge clk);
    s_ports[3] = 4'd4;
    addresses[3] = {mac_c, mac_a};  // src = C, dst = A
    reqs[3] = 1;

    wait (acks[3]);
    $display("T4: P4 Ack, d_port = %0d", d_ports[3]);
    reqs[3] = 0;

    repeat (10) @(posedge clk);
    $finish;
  end

endmodule

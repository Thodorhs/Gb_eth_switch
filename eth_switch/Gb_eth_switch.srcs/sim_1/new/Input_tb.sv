`timescale 1ns / 1ps
import eth_switch_pkg::*;
`define CLK_PERIOD 10

module Input_tb();
    logic clk = 1;
    logic reset_n = 0;
    logic [RXTX_DATA_SIZE-1:0] rx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] rx_ctrl_tb;
    logic [RXTX_DATA_SIZE-1:0] tx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] tx_ctrl_tb;
    
    always #(`CLK_PERIOD/2) clk = ~clk;
    
    eth_switch switch(
        .clk(clk),
        .reset_n(reset_n),
        .rx_data(rx_data_tb),
        .rx_ctrl(rx_ctrl_tb),
        .tx_data(tx_data_tb),
        .tx_ctrl(tx_ctrl_tb)
    );
    
    const logic [0:PACKET_LEN-1] goodpacket = 512'h0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2;
    const logic [0:PACKET_LEN-1] badpacket = 512'h0010A47BEB8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2;
    
    // Stimulus task to send packets
   task send_packets(input logic [0:PACKET_LEN-1] packet);
        int i;
        rx_ctrl_tb = '0;
        rx_data_tb = '0;
        #(2*`CLK_PERIOD);
        
        // Send packet data byte-by-byte
        i = 0;
        while (i < (PACKET_LEN / 8)) begin
            @(posedge clk);
            rx_data_tb = packet[i*8 +: 8];
            rx_ctrl_tb = 4'b1111;
            
            i = i + 1;
        end
        // End of packet: reset rx_ctrl_tb to indicate EOF
        @(posedge clk);
        rx_ctrl_tb = 4'b0000;
        #(1*`CLK_PERIOD);
        
        $display("Packet transmission completed");
    endtask

    
    initial begin
        reset_n = 0;
        rx_data_tb = '0;
        rx_ctrl_tb = '0;
        #(4*`CLK_PERIOD);
        reset_n = 1;
        
        send_packets(goodpacket);
        send_packets(goodpacket);
        send_packets(badpacket);
        
        // Run for some additional time to observe results
        #(20*`CLK_PERIOD);
        
        $display("Simulation completed");
        $finish;
    end
endmodule

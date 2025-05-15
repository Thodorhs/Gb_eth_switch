`timescale 1ns / 1ps
import eth_switch_pkg::*;
`define CLK_PERIOD 10

module cross_tb();
    logic clk = 1;
    logic reset_n = 0;
    logic [RXTX_DATA_SIZE-1:0] rx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] rx_ctrl_tb;
    logic [RXTX_DATA_SIZE-1:0] tx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] tx_ctrl_tb;
    sw_bus_t r2s;
    logic switch_req;
    logic [NUM_OF_PORTS-1:0] packet_done;
    always #(`CLK_PERIOD/2) clk = ~clk;
    logic switch_ack;
    logic [NUM_OF_PORTS-1:0] out_ack;
   crossbar  #(0) crossb (
    .clk(clk),
    .rst_n(reset_n),
    .i_r2s(r2s),
    .i_switch_req(switch_req),
    .i_out_ack(out_ack),
    .i_packet_done(packet_done),
    .o_switch_ack(switch_ack)
   );
    
    const logic [0:PACKET_LEN-1] goodpacket = 512'h0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2;
    const logic [0:PACKET_LEN-1] badpacket = 512'h0010A47BEB8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2;
    
    // Stimulus task to send packets
   task send_packets(input logic [0:PACKET_LEN-1] packet, PORT_t target_port);
        int i;
        packet_done = 0;
        rx_ctrl_tb = '0;
        rx_data_tb = '0;
        #(2*`CLK_PERIOD);
        
        // Send packet data byte-by-byte
        i = 0;
        switch_req =1 ;
        //if(target_port == ALL_PORTS)
        r2s.target_port = target_port;
        //switch_req = 0;
        while (i < (PACKET_LEN / 8)) begin
            @(posedge clk);
            switch_req=0;
            r2s.flit = packet[i*8 +: 8];
            //r2s.target_port = PORT0;
            rx_ctrl_tb = 4'b1111;
            
            i = i + 1;
        end
        // End of packet: reset rx_ctrl_tb to indicate EOF
        if(target_port == ALL_PORTS) begin
            packet_done = '1;
            out_ack = '1;
        end
        else begin
            packet_done[target_port] = 1;
            out_ack[target_port] = 1;
        end
       
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
        
        send_packets(goodpacket,ALL_PORTS);
        send_packets(goodpacket,ALL_PORTS);
        //send_packets(goodpacket);
        //send_packets(badpacket);
        
        // Run for some additional time to observe results
        #(100*`CLK_PERIOD);
        
        $display("Simulation completed");
        $finish;
    end
endmodule

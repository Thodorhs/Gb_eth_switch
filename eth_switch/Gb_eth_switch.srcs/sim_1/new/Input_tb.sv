`timescale 1ns / 1ps
import eth_switch_pkg::*;
`define CLK_PERIOD 10

module Input_tb();
    // Testbench signals
    logic clk = 1;
    logic reset_n = 0;
    logic [RXTX_DATA_SIZE-1:0] rx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] rx_ctrl_tb;
    logic [RXTX_DATA_SIZE-1:0] tx_data_tb;
    logic [RXTXCTRL_BITS_SIZE-1:0] tx_ctrl_tb;
    
    // Clock generation
    always #(`CLK_PERIOD/2) clk = ~clk;
    
    // Device under test (DUT) instantiation
    eth_switch switch(
        .clk(clk),
        .reset_n(reset_n),
        .rx_data(rx_data_tb),
        .rx_ctrl(rx_ctrl_tb),
        .tx_data(tx_data_tb),
        .tx_ctrl(tx_ctrl_tb)
    );
    // Network packet data constants for testing
    // The same packet data from VHDL test bench
    const logic [0:PACKET_LEN-1] packet1 = 512'h0010A47BEA8000123456789008004500002EB3FE000080110540C0A8002CC0A8000404000400001A2DE8000102030405060708090A0B0C0D0E0F1011E6C53DB2;
    
    // Stimulus task to send packets
   task send_packets();
        int i;
        
        // Reset cycle
        reset_n = 0;
        rx_ctrl_tb = '0;
        rx_data_tb = '0;
        #(2*`CLK_PERIOD);
        reset_n = 1;
        #(`CLK_PERIOD);
        
        // Send packet data byte-by-byte
        i = 0;
        while (i < (PACKET_LEN / 8)) begin
            @(posedge clk);
            
            // Send each byte from the packet to rx_data_tb
            rx_data_tb = packet1[i*8 +: 8];  // Get 8 bits at a time from packet1
            
            // Optional: Print out the current byte being sent
            //$display("Sending byte %d: %h", i, rx_data_tb);
            
            // Control signals to indicate packet data transmission
            rx_ctrl_tb = 4'b1111;  // Assuming `rx_ctrl_tb` uses a 4-bit control signal
            
            i = i + 1;
        end
        
        
        // End of packet: reset rx_ctrl_tb to indicate EOF
        @(posedge clk);
        rx_ctrl_tb = 4'b0000;
        #(10*`CLK_PERIOD);
        
        $display("Packet transmission completed");
    endtask

    
    // Main test sequence
    initial begin
        // Initialize signals
        rx_data_tb = '0;
        rx_ctrl_tb = '0;
        
        // Wait for a few clock cycles before starting
        #(5*`CLK_PERIOD);
        
        // Send the test packets
        send_packets();
        
        // Run for some additional time to observe results
        #(20*`CLK_PERIOD);
        
        // End simulation
        $display("Simulation completed");
        $finish;
    end
    
    // Optional: Monitor outputs
    initial begin
        $monitor("Time=%t, tx_data=%h, tx_ctrl=%b", $time, tx_data_tb, tx_ctrl_tb);
    end

endmodule

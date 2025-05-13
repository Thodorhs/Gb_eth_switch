`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2025 11:08:45 PM
// Design Name: 
// Module Name: mac_learning_fsm
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
module mac_learning_fsm (
    input  logic             clk,
    input  logic             reset,

    // Port 1
    input  logic [95:0]      addresses_1,
    input  logic [3:0]       s_port_1,
    input  logic             req_1,
    output logic             ack_1,
    output logic [3:0]       d_port_1,

    // Port 2
    input  logic [95:0]      addresses_2,
    input  logic [3:0]       s_port_2,
    input  logic             req_2,
    output logic             ack_2,
    output logic [3:0]       d_port_2,

    // Port 3
    input  logic [95:0]      addresses_3,
    input  logic [3:0]       s_port_3,
    input  logic             req_3,
    output logic             ack_3,
    output logic [3:0]       d_port_3,

    // Port 4
    input  logic [95:0]      addresses_4,
    input  logic [3:0]       s_port_4,
    input  logic             req_4,
    output logic             ack_4,
    output logic [3:0]       d_port_4
);
    
    mac_table_entry_t mac_table [0:TABLE_SIZE-1];
    
    logic [1:0] current_port;
    logic [11:0] hashed_index_src, hashed_index_dst;
    logic [51:0] read_mac_entry;
    logic mac_match=0;
    
    state_t current_state, next_state;
    logic [47:0] src_mac, dest_mac;
    logic [3:0] src_port;
    
    function automatic logic [TABLE_ADDR_WIDTH-1:0] hash_mac(input logic [47:0] mac);
        logic [TABLE_ADDR_WIDTH-1:0] hash;
    
        // Split the MAC into 6 bytes and XOR them folded into the hash width
        hash = 0;
        hash ^= mac[47:40];
        hash ^= mac[39:32];
        hash ^= mac[31:24];
        hash ^= mac[23:16];
        hash ^= mac[15:8];
        hash ^= mac[7:0];
    
        // Final mixing
        hash = hash ^ (hash >> (TABLE_ADDR_WIDTH / 2));
    
        // Limit the result to TABLE_ADDR_WIDTH bits
        hash = hash & ((1 << TABLE_ADDR_WIDTH) - 1);
    
        return hash;
    endfunction


    
    always_ff @(posedge clk or negedge reset) begin
        if (~reset) begin
            current_state <= CHECK_P1;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
    // default assignments
    ack_1 = 0;
    ack_2 = 0;
    ack_3 = 0;
    ack_4 = 0;
    d_port_1 = 4'b0000;
    d_port_2 = 4'b0000;
    d_port_3 = 4'b0000;
    d_port_4 = 4'b0000;

    case (current_state)
        CHECK_P1: begin
            if (req_1) begin
                src_mac = addresses_1[95:48];
                dest_mac = addresses_1[47:0];
                src_port = s_port_1;
                current_port = 2'd0;
                next_state = HASHING_SRC;
            end else begin
                next_state = CHECK_P2;
            end
        end
        CHECK_P2: begin
            if (req_2) begin
                src_mac = addresses_2[95:48];
                dest_mac = addresses_2[47:0];
                src_port = s_port_2;
                current_port = 2'd1;
                next_state = HASHING_SRC;
            end else begin
                next_state = CHECK_P3;
            end
        end
        CHECK_P3: begin
            if (req_3) begin
                src_mac = addresses_3[95:48];
                dest_mac = addresses_3[47:0];
                src_port = s_port_3;
                current_port = 2'd2;
                next_state = HASHING_SRC;
            end else begin
                next_state = CHECK_P4;
            end
        end
        CHECK_P4: begin
            if (req_4) begin
                src_mac = addresses_4[95:48];
                dest_mac = addresses_4[47:0];
                src_port = s_port_4;
                current_port = 2'd3;
                next_state = HASHING_SRC;
            end else begin
                next_state = CHECK_P1;
            end
        end
        HASHING_SRC: begin
            hashed_index_src = hash_mac(src_mac);
            next_state = HASHING_DEST;
        end
        HASHING_DEST: begin
            hashed_index_dst = hash_mac(dest_mac);
            next_state = TABLE_PROCESSES;
        end
        TABLE_PROCESSES: begin
            mac_table[hashed_index_src] = {src_mac, src_port};
            read_mac_entry = mac_table[hashed_index_dst];
            next_state = COMPARE_MAC;
        end
        COMPARE_MAC: begin
            if (read_mac_entry[51:4] == dest_mac)
                mac_match = 1;
            else
                mac_match = 0;
            next_state = SEND_ACK;
        end
        SEND_ACK: begin
            case (current_port)
                2'd0: begin
                    ack_1 = 1;
                    d_port_1 = mac_match ? read_mac_entry[3:0] : 4'b1111;
                    next_state = CHECK_P2;
                end
                2'd1: begin
                    ack_2 = 1;
                    d_port_2 = mac_match ? read_mac_entry[3:0] : 4'b1111;
                    next_state = CHECK_P3;
                end
                2'd2: begin
                    ack_3 = 1;
                    d_port_3 = mac_match ? read_mac_entry[3:0] : 4'b1111;
                    next_state = CHECK_P4;
                end
                2'd3: begin
                    ack_4 = 1;
                    d_port_4 = mac_match ? read_mac_entry[3:0] : 4'b1111;
                    next_state = CHECK_P1;
                end
            endcase
        end
        default: next_state = CHECK_P1;
    endcase
end


endmodule

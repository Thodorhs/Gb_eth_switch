`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2025 08:13:16 PM
// Design Name: 
// Module Name: SOF_EOF_ctrl
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

module SOF_EOF_ctrl(
    input  logic clk,
    input  logic reset_n,
    input  logic rx_ctrl,
    output logic SOF,  // Start of frame: rx_ctrl rising edge
    output logic EOF   // End of frame:   rx_ctrl falling edge
);

    logic rx_ctrl_ff;

    always_ff @(posedge clk, negedge reset_n) begin
        if (~reset_n) begin
            SOF <= 0;
            EOF <= 0;
            rx_ctrl_ff <= 0;
        end
        else begin
            rx_ctrl_ff <= rx_ctrl;
            SOF <= (rx_ctrl == 1'b1 && rx_ctrl_ff == 1'b0);
            EOF <= (rx_ctrl == 1'b0 && rx_ctrl_ff == 1'b1);
        end
    end

endmodule

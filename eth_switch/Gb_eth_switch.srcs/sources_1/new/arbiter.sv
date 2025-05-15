`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/18/2025 04:08:13 AM
// Design Name: 
// Module Name: arbiter
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


module arbiter(
    input clk,
    input rst_n,
    input logic [3:0] req,
    output logic [3:0] grant
    );
    logic [1:0] pointer_req, next_pointer_req;
  
  always @(posedge clk,negedge rst_n) begin
    if (~rst_n) pointer_req <= '0;
    else     pointer_req <= next_pointer_req;
    
  end
  
  always_comb begin
    next_pointer_req = 3'b000;
    case (grant)
      4'b0001: next_pointer_req =  2'b01 ;
      4'b0010: next_pointer_req =  2'b10 ;
      4'b0100: next_pointer_req =  2'b11 ;
      4'b1000: next_pointer_req =  2'b00 ;
 
    endcase
  end 
    
    always_comb begin
	case (pointer_req)
		2'b00 :
			if (req[0]) grant = 4'b0001;
			else if (req[1]) grant = 4'b0010;
			else if (req[2]) grant = 4'b0100;
			else if (req[3]) grant = 4'b1000;
			else grant = 4'b0000;
		2'b01 :
			if (req[1]) grant = 4'b0010;
			else if (req[2]) grant = 4'b0100;
			else if (req[3]) grant = 4'b1000;
			else if (req[0]) grant = 4'b0001;
			else grant = 4'b0000;
        2'b10 :
			if (req[2]) grant = 4'b0100;
			else if (req[3]) grant = 4'b1000;
			else if (req[0]) grant = 4'b0001;
			else if (req[1]) grant = 4'b0010;
			else grant = 4'b0000;
		2'b11 :
			if (req[3]) grant = 4'b1000;
			else if (req[0]) grant = 4'b0001;
			else if (req[1]) grant = 4'b0010;
			else if (req[2]) grant = 4'b0100;
			else grant = 4'b0000;
	endcase // case(req)
end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 07:54:37
// Design Name: D ff
// Module Name: dff
// Project Name: Verification
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


module dff (dff_if vif);
 
  //posedge from clk
  always @(posedge vif.clk)
    begin
      if (vif.rst == 1'b1)
        // If reset is active, set the output to 0
        vif.dout <= 1'b0;
      else
        vif.dout <= vif.din;
    end
  
endmodule
 
interface dff_if;
  logic clk;   
  logic rst;   
  logic din;   
  logic dout;  
  
endinterface

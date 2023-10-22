`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.10.2023 11:55:02
// Design Name: 
// Module Name: top
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


module top (
input clk, rst, newd,
input [11:0] din,
output [11:0] dout,
output done
);
wire sclk, cs, mosi;
spi_master m1 (clk, newd, rst, din, sclk, cs, mosi);
spi_slave s1  (sclk, cs, mosi, dout, done);
endmodule
interface spi_if;
  logic clk,rst,newd,sclk;        // Flags indicating FIFO status
  logic [11:0] din;         // Data input
  logic [11:0] dout;        // Data output
  logic done;                   // Reset signal
endinterface


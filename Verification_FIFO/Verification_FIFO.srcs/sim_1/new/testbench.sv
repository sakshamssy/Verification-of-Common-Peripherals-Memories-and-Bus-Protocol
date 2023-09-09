`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.09.2023 10:42:41
// Design Name: 
// Module Name: testbench
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

class transaction;

rand bit rd,wr;
rand bit [7:0] data_in;
bit full, empty;
bit [7:0] data_out;


constraint wr_rd {
    rd!=wr;
    wr dist { 0:/50 , 1:/50};
    rd dist { 0:/50 , 1:/50}; // := could be used to //similar meanings here
    }
    
   function void display(input string tag);
$display("[%0s] : WR : %0b\t RD:%0b\t DATAWR : %0d\t DATARD : %0d\t FULL : %0b\t EMPTY : %0b @ %0t", tag, wr, rd, data_in, data_out, full, empty,$time); 
   
   endfunction 
   
   function transaction copy();
    copy = new();
    copy.rd=this.rd;
    copy.wr = this.wr;
    copy.data_in = this.data_in;
    copy.data_out= this.data_out;
    copy.full = this.full;
    copy.empty = this.empty;   
   endfunction
    endclass
    
module testbench;
transaction tr;
initial begin 
tr=new();
tr.display("TOP MODULE");
end 
endmodule

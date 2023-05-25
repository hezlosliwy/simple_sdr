`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2023 10:30:19 PM
// Design Name: 
// Module Name: random_err
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


module random_err(
    input wire clk,
    input wire rst,
    input wire ready_out,
    input wire valid_in,
    input wire data_in,
    output reg data_out
    );

    int i = 0;
    int temp,temp2;
    initial begin
        temp = $urandom_range(0,62);
        temp2 = $urandom_range(0,62);
    end
    
    assign ready_in = ready_out;
    assign data_out = ( i == temp || i ==temp2 )? 1^data_in : data_in;
    always @ (posedge clk) begin
        if(i == 62 && ready_out && valid_in ==1 )begin
            if ( i == temp || i ==temp2 ) begin
                i = 0;
                temp = $urandom_range(0,62);
                temp2 = $urandom_range(0,62);
            end
            else begin
                i = 0;
                temp = $urandom_range(0,62);
                temp2 = $urandom_range(0,62);
            end
        end
        else if (ready_out == 1 && valid_in ==1 ) begin
                i = i+1;
        end
     end
endmodule
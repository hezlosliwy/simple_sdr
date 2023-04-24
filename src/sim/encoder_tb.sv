`timescale 1ns / 1ps
module encoder_tb(
    
    );
    reg clk =0;
    reg rst = 0; 
    reg data_in;
    reg [50:0] data_in_all = 51'b010110101101001111001110100100000010101111010001100;
    //56'b11011100110101011101000100101000101010111010101011110101;
    reg [62:0] data_out;
    reg ready;
    reg ready_in=0;
    always
        #5 clk <= ~clk;
    int i = 7'd50;  
      
    always @(posedge clk) begin
        if(ready)begin
            ready_in=1;
            data_in = data_in_all[i];
            i = i-1;
        end
        if(i<0)begin
            i = 7'd50;
            
        end

    end
        
    
    bch_encoder bch_encoder(
    clk,
    rst,
    ready_in,
    data_in,
    data_in_all,
    data_out,
    ready
    );
    
endmodule

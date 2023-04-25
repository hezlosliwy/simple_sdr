`timescale 1ns / 1ps
module encoder_tb(
    
    );
    reg clk =0;
    reg rst = 0; 
    reg data_in;
    reg [50:0] data_in_all = 51'b011011011110110110001111011001011110011001101100011;
    //56'b11011100110101011101000100101000101010111010101011110101;
    reg [62:0] data_out_all;
    reg data_out;
    reg ready_out;
    reg ready_in=0;
    reg valid_out;
    reg valid_in=0;
    always
        #5 clk <= ~clk;
    int i = 7'd50;  
      
      initial begin
            #10 ready_in=1;
            #10 valid_in=1;
      end
    always @(posedge clk) begin

        if(ready_out)begin

            data_in = data_in_all[i];
            i = i-1;
        end
        if(i<0)begin
            #10
            i = 7'd50;
            
        end

    end
        
    
    bch_encoder bch_encoder(
    clk,
    rst,
    ready_in,
    ready_out,
    valid_in,
    valid_out,
    data_in,
    data_in_all,
    data_out_all,
    data_out
    );

    
endmodule

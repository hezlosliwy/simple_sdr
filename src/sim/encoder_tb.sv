`timescale 1ns / 1ps
module encoder_tb(
    
    );
    reg clk =0;
    reg rst = 0; 
    reg data_in;
    reg [50:0] data_in_all = 51'b011011011110110110001111011001011110011001101100011;
    reg [62:0] data_out_all;
    reg data_out,data_out2;
    reg ready_out,ready_out2;
    reg ready_in=0;
    reg valid_out;
    reg valid_in=0;
    reg out_data ;
    reg out_valid ,out_ready;
    reg [62:0] checkdata;
    always
        #5 clk <= ~clk;
    int i = 7'd50;  
      
      initial begin
             rst = 1; repeat(2)@(posedge clk);rst = 0;
//           10 ready_in=1;
            #10 valid_in=1;
      end
    always @(posedge clk) begin

        if(ready_in)begin

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
    ready_out,
    valid_in,
    valid_out,
    data_in,
    data_in_all,
    data_out_all,
    data_out
    );
    
    random_err random_err(
    clk,
    rst,
    ready_out,
    valid_out,
    data_out,
    data_out2
    );
    
    bch_decoder bch_decoder(
    clk,
    rst,
    valid_out,
    data_out2,
    ready_out,
    out_valid,
    out_data,
    1'b1
    );
    
     always @(posedge clk) begin
        checkdata<={checkdata[61:0],out_data};
     end
endmodule

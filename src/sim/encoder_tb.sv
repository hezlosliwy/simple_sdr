`timescale 1ns / 1ps
module encoder_tb(
    
    );
    reg clk =0;
    reg rst = 0; 
    reg data_in;
    reg [50:0] data_in_all [9:0] = {51'b100001001010111101101000011010000010010110101010110,51'b000100000011100011010110000100101001000011111000101,
    51'b011011011110110110001111011001011110011001101100011,51'b101010011100110010001100011010111101110001000101011,
    51'b010110101101001111001110100100000010101111010001100,51'b101010111111011101100001011001110001110011001110011,
    51'b011111100000110011101001010100011001001011110100100,51'b100001010110010011100011011011000001000010101010010,
    51'b110001000110110101011101010110101110101001010101110,51'b110101000010001001001000000100010111100011010110011};
    reg [50:0] data_in_all_tmp;
    reg [50:0] data_in_all_prev;
    int temp;
    int i_c=0; 
    reg [62:0] data_out_all;
    reg data_out,data_out2;
    reg ready_out,ready_out2;
    reg ready_in=0;
    reg valid_out;
    reg valid_in=0;
    reg out_data ;
    reg checking;
    reg out_valid ,out_ready;
    reg [50:0] checkdata;
    always
        #5 clk <= ~clk;
    int i = 7'd50;  
      
      initial begin
             rst = 1; repeat(2)@(posedge clk);rst = 0;
             temp = $urandom_range(0,9);
             data_in_all_tmp = data_in_all[temp];
//           10 ready_in=1;
            #10 valid_in=1;
      end
    always @(posedge clk) begin
        
        if(ready_in)begin
           // if
            
            
            data_in = data_in_all_tmp[i];
            i = i-1;
        end
        if(i<0)begin
            data_in_all_prev = data_in_all_tmp;
            temp = $urandom_range(0,9);
            data_in_all_tmp = data_in_all[temp];
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
    
    task check (input [50:0] checkdata, input [50:0] data_in_all_prev);
        
        begin
            if(checkdata == data_in_all_prev)
                $display("test passed",checkdata,"   " ,data_in_all_prev);
            else
                $display("test failed",checkdata,"   " ,data_in_all_prev);
        end   
    endtask
    
    
    always @(posedge clk )begin
        if(out_valid == 1)begin
            checkdata<={checkdata[50:0],out_data};
            i_c <= (i_c + 1)%51;
            checking<= 0;
        end
        if(i_c==0 && checking == 0)begin
            checking<=1;
            check(checkdata,data_in_all_prev);
        end
    end 
    
//        checkdata<={checkdata[50:0],out_data};
//        if(i==50 && (checkdata[50]==0||checkdata[50]==1))begin
//            if(checkdata == data_in_all_prev)
//                $display("test passed",checkdata,"   " ,data_in_all_prev);
//            else
//                $display("test failed",checkdata,"   " ,data_in_all_prev);
//        end
        
endmodule
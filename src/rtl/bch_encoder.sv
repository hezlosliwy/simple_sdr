`timescale 1ns / 1ps

module bch_encoder(
        input wire clk,
        input wire rst,
        input wire ready_in,
        input wire data_in,
        input wire [50:0] data_in_all,
        output reg [62:0] data_out,
        output reg ready
    );
    //reg [7:0] exp =  8'b11000101;
    //reg [12:0] exp =  13'b1010100111001;
    int counter = 0;
    reg [50:0] tmp = 0; 
    reg [12:0] rest = 0; 
    int i =0;    
    initial 
        ready<=1;
    always @ (posedge clk) begin
        tmp[50-counter]<=data_in;
        ready<=1;         
        rest[0] <= data_in ^ rest[11]; 
        rest[1] <= rest[0]; 
        rest[2] <= rest[1];
        rest[3] <= rest[2] ^ (data_in  ^ rest[11]);
        rest[4] <= rest[3] ^ (data_in  ^ rest[11]);
        rest[5] <= rest[4] ^ (data_in  ^ rest[11]);
        rest[6] <= rest[5];
        rest[7] <= rest[6];
        rest[8] <= rest[7] ^ (data_in  ^ rest[11]);
        rest[9] <= rest[8];
        rest[10] <= rest[9] ^ (data_in  ^ rest[11]);
        rest[11] <= rest[10];
        counter <= (ready_in)?(counter + 1)%52:counter;
        if(counter == 51)begin 
            ready <=0;
            data_out <= {tmp[50:0],rest[11:0]};
            rest <= 0;
        end
         
    end
    
endmodule

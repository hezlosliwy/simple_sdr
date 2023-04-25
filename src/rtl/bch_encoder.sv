`timescale 1ns / 1ps

module bch_encoder(
        input wire clk,
        input wire rst,
        input wire ready_in,
        output reg ready_out,
        input wire valid_in,
        output reg valid_out,
        input wire data_in,
        input wire [50:0] data_in_all,
        output reg [62:0] data_out_all,
        output reg data_out
    );
    //reg [7:0] exp =  8'b11000101;
    //reg [12:0] exp =  13'b1010100111001;
    typedef enum {IDLE, RESET, WORK, REST} state_t;
    state_t state;
    int counter = 0;
    reg [62:0] tmp = 0; 
    reg [12:0] rest = 0; 
 
    always @ (posedge clk) begin
        if(rst)begin
            state <= IDLE;
            counter <= 0;
            tmp <= 0;
            rest <= 0;
        end
        else begin
            case (state)
                IDLE: begin
                    if(valid_in && ready_in == 1)begin
                        state<=WORK;
                    end
                end
                WORK: begin
                        counter <= ((ready_in)&&(valid_in))?(counter + 1)%63:counter;
                        state<=((counter < 50))?WORK:REST;
                        
                end
                REST: begin
                        state<=(counter <= 62)?REST:RESET;
                        counter <= (ready_in)?(counter + 1):counter;
                end
                RESET: begin
                        state<=IDLE;
                        rest <=0;
                        tmp<=0;
                        counter<=0;
                end
                
            endcase    
        end    
    end
    
    assign ready_out = ((state==WORK)&&ready_in)?1 :0;
    
    
    always @ (posedge clk) begin
        if(state == WORK && (ready_in)&&(valid_in) )begin
            tmp[62-counter]<=data_in;
            data_out <= data_in;
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
        end
        else if(state == REST && (ready_in))begin
            tmp[62-counter]<=rest[62-counter];
            data_out_all <= {data_in_all[50:0],rest[11:0]};//all data out
            data_out<=rest[62-counter];
            rest[12:0]<=rest[12:0];
        end
         
    end
    
endmodule

`timescale 1ns / 1ps

module bch_encoder(
        input wire clk,
        input wire rst,
        output wire ready_in,
        input reg ready_out,
        input wire valid_in,
        output reg valid_out,
        input wire data_in,
        output reg data_out
    );
    typedef enum {IDLE, RESET, WORK, REST} state_t;
    state_t state;
    int counter = 0;
    reg [11:0] rest = 0; 
 
    always @ (posedge clk) begin
        if(rst)begin
            state <= IDLE;
            counter <= 0;
            valid_out<=0;
        end
        else begin
            case (state)
                IDLE: begin
                        state<=WORK;
                        valid_out <= 0;
                end
                WORK: begin
                    if(valid_in & ready_out) begin
                        counter <= counter + 1;
                        state<=((counter < 50))?WORK:REST;
                        valid_out <= 1'b1;
                    end
                end
                REST: begin
                    if(ready_out) begin
                        valid_out <=(counter < 63)?1:0;
                        state<= (counter < 63)?REST:RESET;
                        counter <= counter + 1;
                    end
                end
                RESET: begin
                    if(ready_out) begin
                        state<=WORK;
                        valid_out <= 0;
                        counter<=0;
                    end
                end
                
            endcase    
        end    
    end
    
    assign ready_in = ((state==WORK)&&ready_out) ? 1 : 0;
    
    
    always @ (posedge clk) begin
        if(rst) begin
            rest <= 0;
            data_out <= 0;
        end
        else begin
            if(state == WORK && (ready_out)&&(valid_in) )begin
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
            else if(state == REST && (ready_out))begin
                data_out<=rest[11];
                rest = {rest[10:0],1'b0};
            end
        end
    end
    
endmodule

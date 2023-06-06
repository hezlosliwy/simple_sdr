`timescale 1ns / 1ps

module cordic_360
    (
        input  wire clock,
        input  wire reset,
        input  wire ce,
        input  wire unsigned [11:0] angle,
        output reg  [11:0] x,
        output reg  [11:0] y
    );

    wire signed [11:0] sin_out, cos_out;
    cordic_pipe_rtl i_cordic_pipe_rtl( clock, reset, ce, (angle_reduce[2]<<1), sin_out, cos_out, valid_out );
    reg [1:0] q_tab [14:0];
    reg [3:0] q_ptr = 0;
    reg unsigned [11:0] angle_reduce [2:0];
    reg unsigned [1:0] q_reduce [2:0];

    always @(posedge clock) begin
        angle_reduce[0] <= (angle>803) ? (angle - 803) : angle;
        q_reduce[0] <=  (angle>803) ? 1 : 0;
        for (integer i = 1; i<3 ;i=i+1 ) begin
            angle_reduce[i] <= (angle_reduce[i-1]>803) ? (angle_reduce[i-1] - 803) : angle_reduce[i-1];
            q_reduce[i] <=  (angle_reduce[i-1]>803) ? i+1 : q_reduce[i-1];
        end
    end

    always @(posedge clock) begin
        if(valid_out) begin
            if(q_tab[q_ptr] == 0) begin
                y <= sin_out;
                x <= cos_out;
            end
            else if(q_tab[q_ptr] == 1) begin
                y <= cos_out;
                x <= -sin_out;
            end
            else if(q_tab[q_ptr] == 2) begin
                y <= -sin_out;
                x <= -cos_out;
            end
            else begin
                y <= -cos_out;
                x <= sin_out;
            end
        end
        else begin
            x <= 0;
            y <= 0;
        end
        q_tab[q_ptr] <= q_reduce[2];
        q_ptr <= (q_ptr!=14) ? (q_ptr + 1) : 0 ;
    end

endmodule

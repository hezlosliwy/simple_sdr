`timescale 1ns / 1ps

/*
Module configured in 1R1T DUAL PORT FDD
*/

module ad9363_stream (
  input wire clk,
  input wire rst,
  //internal output stream
  output reg out_valid,
  output reg [11:0] out_data_i,
  output reg [11:0] out_data_q,
  input wire out_ready,
  //internal input stream
  input wire in_valid,
  input wire [11:0] in_data_i,
  input wire [11:0] in_data_q,
  output reg in_ready,
  //external output stream
  output reg fb_clk,
  output reg tx_frame,
  output reg[11:0] p1_d,
  //external input stream
  input wire data_clk,
  input wire rx_frame,
  input wire[11:0] p0_d
);

  typedef enum { ST_IDLE, ST_I, ST_Q }  t_controler_state;
  t_controler_state tx_ctrl_state;

  reg [11:0] in_data_i_int;
  reg [11:0] in_data_q_int;
  reg [11:0] out_data_i_int [1:0];
  reg [11:0] out_data_q_int;
  reg out_valid_int = 1'b0;
  reg is_i;

  // assign fb_clk = ~clk;

  always @(negedge clk) begin
    if(rst) begin
      fb_clk <= 1'b0;
    end
    else begin
      fb_clk <= ~fb_clk;  
    end
  end

  //TX CONTROL
  always @(posedge clk) begin
    if(rst == 1'b1) begin
      tx_ctrl_state <= ST_IDLE;
      in_ready <= 1'b0;
    end 
    else begin
      if(in_valid & in_ready) begin
        in_data_i_int <= in_data_i;
        in_data_q_int <= in_data_q;
      end

      case (tx_ctrl_state)
        ST_IDLE: begin
          if(in_valid & in_ready) begin
            tx_ctrl_state <= ST_I;
            in_ready <= 1'b0;
          end 
          else if(fb_clk) begin
            in_ready <= 1'b1;
          end
        end
        ST_I: begin
          tx_frame <= 1'b1;
          p1_d <= in_data_i_int;
          tx_ctrl_state <= ST_Q;
          in_ready <= 1'b1;
        end
        ST_Q: begin
          tx_frame <= 1'b0;
          p1_d <= in_data_q_int;
          tx_ctrl_state <= in_valid ? ST_I : ST_IDLE;
          in_ready <= in_valid ? 1'b0 : 1'b1;
        end
      endcase
    end
  end

  //RX control
  always @(negedge data_clk) begin
    out_data_i_int[0] <= p1_d;
    out_data_i_int[1] <= out_data_i_int[0];
    if(rx_frame) begin
      is_i <= 1'b1;
    end else begin
      is_i <= 1'b0;
    end
  end



  always @(posedge data_clk) begin
    out_valid_int <= 1'b1;
    out_data_q_int[0] <= p1_d;
    out_data_q_int[1] <= out_data_q_int[0];
  end

  fifo_async
  #(
    .WRITE_DATA_WIDTH(24),
    .READ_DATA_WIDTH(24),
    .DATA_DEPTH(16)
  ) out_fifo
  (
      .rst(rst),
      .in_clk(data_clk),
      .in_valid(out_valid_int),
      .in_ready(),
      .in_data((is_i) ? {out_data_i_int[1],out_data_q_int} : {out_data_q_int, out_data_i_int[0]}),
      .out_clk(clk),
      .out_valid(out_valid),
      .out_ready(out_ready),
      .out_data({out_data_i,out_data_q})
  );

endmodule

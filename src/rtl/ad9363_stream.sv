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
  output wire fb_clk,
  output reg tx_frame,
  output reg p1_d,
  //external input stream
  input wire data_clk,
  input wire rx_frame,
  input wire p0_d
);

  typedef enum t_controler_state { ST_IDLE, ST_I, ST_Q } tx_state;
  t_controler_state tx_ctrl_state;

  reg [11:0] in_data_i_int;
  reg [11:0] in_data_q_int;
  reg [11:0] out_data_i_int;
  reg [11:0] out_data_q_int;
  reg out_valid_int = 1'b0;

  assign fb_clk = ~clk;

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
          else begin
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
  always @(posedge data_clk) begin
    if(rx_frame) begin
      out_data_i_int <= p1_d;
      out_valid_int <= 1'b0;
    end
    else begin
      out_data_q_int <= p1_d;
      out_valid_int <= 1'b1;
    end
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
      .in_data({out_data_i_int,out_data_q_int}),
      .out_clk(clk),
      .out_valid(out_valid),
      .out_ready(out_ready),
      .out_data({out_data_i,out_data_q})
  );

endmodule

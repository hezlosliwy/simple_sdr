`timescale 1ns / 1ps

/*
Module configured in 1R1T DUAL PORT FDD ; SINGLE DATA RATE
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
  output reg[11:0] p1_d,
  //external input stream
  input wire data_clk,
  input wire rx_frame,
  input wire[11:0] p0_d
);

  typedef enum { ST_IDLE, ST_I, ST_Q }  t_controler_state;
  (* MARK_DEBUG = "TRUE" *) t_controler_state tx_ctrl_state;

  reg [11:0] in_data_i_int;
  reg [11:0] in_data_q_int;

  reg [23:0] rx_data;
  reg rx_valid;
  (* MARK_DEBUG = "TRUE" *) reg tx_ready;
  reg tx_valid;
  reg [23:0] tx_data;
  reg arst, arst_sync;

  assign fb_clk = data_clk;

  always @(posedge rst or posedge data_clk) begin
    if(rst) arst_sync <= 1'b1;
    else arst_sync <= 1'b0;
  end

  always @(posedge data_clk) begin
    arst <= arst_sync;
  end

  //TX CONTROL
  always @(posedge data_clk) begin
    if(arst == 1'b1) begin
      tx_ctrl_state <= ST_IDLE;
      tx_ready <= 1'b0;
    end 
    else begin
      if(tx_valid & tx_ready) begin
        in_data_i_int <= tx_data[11:0];
        in_data_q_int <= tx_data[23:12];
      end

      case (tx_ctrl_state)
        ST_IDLE: begin
          if(tx_valid & tx_ready) begin
            tx_ctrl_state <= ST_I;
            tx_ready <= 1'b0;
          end 
          else begin
            tx_ready <= 1'b1;
          end
        end
        ST_I: begin
          tx_frame <= 1'b1;
          p1_d <= in_data_i_int;
          tx_ctrl_state <= ST_Q;
          tx_ready <= 1'b1;
        end
        ST_Q: begin
          tx_frame <= 1'b0;
          p1_d <= in_data_q_int;
          tx_ctrl_state <= tx_valid ? ST_I : ST_IDLE;
          tx_ready <= tx_valid ? 1'b0 : 1'b1;
        end
      endcase
    end
  end

  fifo_async
  #(
    .WRITE_DATA_WIDTH(24),
    .READ_DATA_WIDTH(24),
    .DATA_DEPTH(16)
  ) in_fifo
  (
      .rst(rst),
      .in_clk(clk),
      .in_valid(in_valid),
      .in_ready(in_ready),
      .in_data({in_data_i, in_data_q}),
      .out_clk(data_clk),
      .out_valid(tx_valid),
      .out_ready(tx_ready),
      .out_data(tx_data)
  );

  //RX control
  always @(posedge data_clk) begin
    if(arst) begin
      rx_valid <= 1'b0;
    end
    else begin
      rx_data <= rx_frame ? {rx_data[23:12], p0_d} : {p0_d, rx_data[11:0]};
      rx_valid <= ~rx_frame;
    end
  end

  fifo_async
  #(
    .WRITE_DATA_WIDTH(24),
    .READ_DATA_WIDTH(24),
    .DATA_DEPTH(16)
  ) out_fifo
  (
      .rst(arst),
      .in_clk(data_clk),
      .in_valid(rx_valid),
      .in_ready(),
      .in_data(rx_data),
      .out_clk(clk),
      .out_valid(out_valid),
      .out_ready(out_ready),
      .out_data({out_data_i,out_data_q})
  );

endmodule

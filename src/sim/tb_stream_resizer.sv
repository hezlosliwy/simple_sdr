`timescale 1ns / 1ps

module tb_stream_resizer();

  localparam CLK_PERIOD = 20;

  reg  [7:0] in_data = 0;
  wire [7:0] out_data;
  wire [1:0] int_data;
  reg in_valid = 0;
  reg out_ready;
  reg clk, rst;

  initial begin
    clk = 1'b0;
    forever begin
      clk = #(CLK_PERIOD/2) ~clk;
    end
  end

  initial begin
    rst = 1'b1;
    repeat(4*16)@(posedge clk);
    rst = 1'b0;
  end

  always @(posedge clk) begin
    if(in_ready) begin
      in_data <= $random();
      in_valid <= $random();
    end
    out_ready <= $random();
  end



  stream_resizer
    #(
      .IN_WIDTH(8),
      .OUT_WIDTH(2)
    ) in_resizer
    (
      .clk(clk),
      .rst(rst),
      .in_valid(in_valid),
      .in_data(in_data),
      .in_ready(in_ready),
      .out_valid(int_valid),
      .out_data(int_data),
      .out_ready(int_ready)
    );

  stream_resizer
    #(
      .IN_WIDTH(2),
      .OUT_WIDTH(8)
    ) out_resizer
    (
      .clk(clk),
      .rst(rst),
      .in_valid(int_valid),
      .in_data(int_data),
      .in_ready(int_ready),
      .out_valid(out_valid),
      .out_data(out_data),
      .out_ready(out_ready)
    );

endmodule

`timescale 1ns / 1ps

module tb_ad9363_stream ();

logic clk, rst = 1'b1;

logic [11:0] out_ad_data_i, in_ad_data_i;
logic [11:0] out_ad_data_q, in_ad_data_q;
logic out_ad_valid, in_ad_valid;
logic out_ad_ready, in_ad_ready;

logic ad_clk, fb_clk, ad_frame;
logic [11:0] ad_data;

initial begin
  clk = 1'b0;
  forever begin
    clk = #5 ~clk;
  end
end

initial begin
  ad_clk = 1'b0;
  forever begin
    ad_clk = #23 ~ad_clk;
  end
end

initial begin
  @(negedge clk) rst = 1'b1;
  #120;
  @(negedge clk) rst = 1'b0;
  forever begin
    @(posedge in_ad_ready);
    in_ad_valid = 1'b1;
    in_ad_data_i = $random();
    in_ad_data_q = $random();
    out_ad_ready = 1'b1;  
  end
  
  #10000;
end

ad9363_stream my_ad9363_stream(
  .clk(clk),
  .rst(rst),
  //internal output stream
  .out_valid(out_ad_valid),
  .out_data_i(out_ad_data_i),
  .out_data_q(out_ad_data_q),
  .out_ready(out_ad_ready),
  //internal input stream
  .in_valid(in_ad_valid),
  .in_data_i(in_ad_data_i),
  .in_data_q(in_ad_data_q),
  .in_ready(in_ad_ready),
  //external output stream
  .fb_clk(fb_clk),
  .tx_frame(ad_frame),
  .p1_d(ad_data),
  //external input stream
  .data_clk(ad_clk),
  .rx_frame(ad_frame),
  .p0_d(ad_data)
);

endmodule

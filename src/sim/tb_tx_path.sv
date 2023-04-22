`timescale 1ns / 1ps

module tb_tx_path;

localparam CLK_PERIOD = 20;
localparam DATA_LEN   = 100;

logic clk;
logic rst;
logic i_I, i_Q;
logic [11:0] o_I, o_Q;
logic i_valid;
logic o_ready;
logic o_valid;
logic i_out_ready;

initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

logic [14:0] data_i = '0;

task automatic parallel_input();
  i_valid = 1'b1;
  i_I = 1'b0;
  i_Q = 1'b0;
  for(int i=0; i < (DATA_LEN); i=i+1) begin
    if (o_ready) begin
      i_I = $random();
      i_Q = $random();
      $display("%t \tI=%d \tQ=%d",$time,i_I,i_Q);
    end
    @(posedge clk);
  end
  i_out_ready = 1'b0;
  repeat(4) @(posedge clk);
  $finish();
endtask

initial begin : main
  rst = 1'b1;
  i_out_ready = 1'b0;
  repeat(2)@(posedge clk);
  rst = 1'b0;
  i_out_ready = 1'b1;
  forever begin 
    parallel_input();
  end
end

TX_path_top u_qpsk_mod (
  .clk(clk),
  .rst(rst),
  //internal output stream
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
  .out_valid(o_valid),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
  .out_data({o_I, o_Q}), //i q
  //(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
  .out_ready(i_out_ready),
  //internal input stream
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
  .in_valid(i_valid),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
  .in_data(),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
  .in_ready(o_ready),
  //external output stream
  //external input stream
  .in_I(i_I), // temporary
  .in_Q(i_Q)  // temporary
);



endmodule
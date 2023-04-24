`timescale 1ns / 1ps

module tb_tx_path;
import logger_pkg::*;

logger logger_local;

localparam CLK_PERIOD = 20;
localparam DATA_LEN   = 100*8;

logic clk;
logic rst;
logic i_I, i_Q;
logic [11:0] o_I, o_Q;
logic i_valid;
logic o_ready;
logic o_valid;
logic i_out_ready;

logic fir_ready;
logic fir_o_data_valid;
logic [15:0] fir_I_output, fir_Q_output;

string i_out_vect = "", q_out_vect = "";

initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

task automatic parallel_input();
  i_valid = 1'b1;
  i_I = 1'b0;
  i_Q = 1'b0;
  for(int i=0; i < (DATA_LEN); i=i+1) begin
    if (o_ready) begin
      i_I = $random();
      i_Q = $random();
      logger_local.log($sformatf("I=%d \tQ=%d",i_I,i_Q));
    end
    @(posedge clk);
  end
  i_out_ready = 1'b0;
  repeat(4) @(posedge clk);
  logger_local.summary();
  logger_local.log("Output recorded:");
  logger_local.log({"I: ",i_out_vect});
  logger_local.log({"Q: ",q_out_vect});
  $finish();
endtask

always@(posedge clk) begin : save_output;
  @(posedge clk);
  if (o_valid) begin
    if (o_I == 12'h5a7) i_out_vect = {i_out_vect, "1.0,"};
    else if (o_I == 12'ha59) i_out_vect = {i_out_vect, "-1.0,"};
    else i_out_vect = {i_out_vect, "X.X,"};

    if (o_Q == 12'h5a7) q_out_vect = {q_out_vect, "1.0,"};
    else if (o_Q == 12'ha59) q_out_vect = {q_out_vect, "-1.0,"};
    else q_out_vect = {q_out_vect, "X.X,"};
  end
end

initial begin : main
  logger_local.init();

  rst = 1'b1;
  i_out_ready = 1'b0;
  repeat(4)@(posedge clk);
  rst = 1'b0;
  i_out_ready = 1'b1;
  forever begin 
    parallel_input();
  end
end

TX_path_top DUT (
  .clk(clk),
  .rst(rst),
  //internal output stream
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
  .out_valid(o_valid),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
  .out_data({o_I, o_Q}), //i q
  //(* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
  .out_ready(fir_ready),
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

fir_compiler_0 my_fir (
  .s_axis_data_tdata  ({{4'h0},o_I,{4'h0},o_Q}),
  .s_axis_data_tready (fir_ready),
  .s_axis_data_tvalid (o_valid),
  .aclk               (clk),
  .aresetn            (~rst),

  .m_axis_data_tdata  ({fir_I_output,fir_Q_output}),
  .m_axis_data_tready (i_out_ready),
  .m_axis_data_tvalid (fir_o_data_valid)
);


endmodule
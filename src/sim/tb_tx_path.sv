`timescale 1ns / 1ps

module tb_tx_path;
// import logger_pkg::*;

// logger logger_local;

localparam CLK_PERIOD = 20;
localparam DATA_LEN   = 100*8;

logic clk, out_clk;
logic rst = 1'b1;
logic i_I, i_Q;
logic [11:0] o_I, o_Q;
logic i_valid;
logic o_ready;
logic o_valid;
logic i_out_ready;

logic fir_ready;
logic fir_o_data_valid;
logic [15:0] fir_I_output, fir_Q_output;
logic [11:0] fifo_I_output, fifo_Q_output;

logic [7:0] in_stream_data;

string i_out_vect = "", q_out_vect = "";

initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

initial begin
  out_clk = 1'b0;
  forever begin
    out_clk = #(CLK_PERIOD/16) ~out_clk;
  end
end

// task automatic parallel_input();
//   i_valid = 1'b1;
//   i_I = 1'b0;
//   i_Q = 1'b0;
//   for(int i=0; i < (DATA_LEN); i=i+1) begin
//     if (o_ready) begin
//       i_I = $random();
//       i_Q = $random();
//       logger_local.log($sformatf("I=%d \tQ=%d",i_I,i_Q));
//     end
//     @(posedge clk);
//   end
//   // i_out_ready = 1'b0;
//   repeat(4) @(posedge clk);
//   logger_local.summary();
//   logger_local.log("Output recorded:");
//   logger_local.log({"I: ",i_out_vect});
//   logger_local.log({"Q: ",q_out_vect});
//   // $finish();
// endtask

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(1),
    .FILE_NAME("tb.in")
) in_source
  (
    .clk(clk),
    .rst(rst),
    .out_data(in_stream_data),
    .out_valid(in_stream_valid),
    .out_ready(in_stream_ready),
    .eof()
  );

logic [1:0] in_data_cnt;
assign in_stream_ready = in_data_cnt==0 & o_ready;
always @(posedge clk) begin
  if(rst) begin
    in_data_cnt <= 2'b0;
  end
  else if(o_ready) begin
    in_data_cnt <= in_data_cnt + 1;
    if(in_data_cnt==0) begin
      i_I <= in_stream_data[2*in_data_cnt];
      i_Q <= in_stream_data[2*in_data_cnt+1];
    end
  end
end

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
  // logger_local.init();

  rst = 1'b1;
  repeat(4*16)@(posedge clk);
  rst = 1'b0;
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
  .in_valid(1'b1),
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

fifo_async
#(
  .WRITE_DATA_WIDTH(24),
  .READ_DATA_WIDTH(24),
  .DATA_DEPTH(16)
) in_fifo
(
    .rst(rst),
    .in_clk(clk),
    .in_valid(fir_o_data_valid),
    .in_ready(i_out_ready),
    .in_data({fir_I_output[11:0],fir_Q_output[11:0]}),
    .out_clk(out_clk),
    .out_valid(fifo_out_valid),
    .out_ready(1'b1),
    .out_data({fifo_I_output,fifo_Q_output})
);

endmodule
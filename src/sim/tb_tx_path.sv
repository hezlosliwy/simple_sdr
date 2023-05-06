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
logic [15:0] out_stream_data_i, out_stream_data_q;

logic [7:0] in_stream_data, in_stream_data_int;
logic in_valid_dut = 1'b0;

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
    out_clk = #(CLK_PERIOD/2*8) ~out_clk;
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
logic have_data = 1'b0;
assign in_stream_ready = in_data_cnt==0 & o_ready & ~have_data;

assign i_I = in_stream_data_int[7];
assign i_Q = in_stream_data_int[6];


always @(posedge clk) begin
  if(rst) begin
    in_data_cnt <= 2'b0;
  end
  else if(o_ready) begin
    in_data_cnt <= in_data_cnt + 1;
    if(in_data_cnt==0) begin
      in_valid_dut <= 1'b1;
      in_stream_data_int <= in_stream_data;
      have_data <= 1'b1;
    end
    else begin
      if(in_data_cnt==3) begin
        have_data <= 1'b0;
      end
      in_stream_data_int <= {in_stream_data_int[5:0], 2'b0};
    end
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
  .in_valid(in_valid_dut),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
  .in_data(),
  // (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
  .in_ready(o_ready),
  //external output stream
  //external input stream
  .in_I(i_I), // temporary
  .in_Q(i_Q)  // temporary
);

// fir my_fir(
//     .clk(clk),
//     .rst(rst),
//     .in_valid(o_valid),
//     .in_data_i(o_I),
//     .in_data_q(o_Q),
//     .in_ready(fir_ready),
//     .out_valid(fir_o_data_valid),
//     .out_data_i(fir_I_output),
//     .out_data_q(fir_Q_output),
//     .out_ready(i_out_ready)
//   );

logic [3:0] tr1, tr2;

fir_compiler_0 my_fir(
  .aclk(clk),
  .aresetn(~rst),
  .s_axis_data_tvalid(o_valid),
  .s_axis_data_tdata({4'b0, o_I, 4'b0, o_Q}),
  .s_axis_data_tready(fir_ready),
  .m_axis_data_tvalid(fir_o_data_valid),
  .m_axis_data_tdata({ fir_I_output, fir_Q_output}),
  .m_axis_data_tready(i_out_ready)
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
    .in_data({fir_I_output[11:0], fir_Q_output[11:0]}),
    .out_clk(out_clk),
    .out_valid(fifo_out_valid),
    .out_ready(1'b1),
    .out_data({fifo_I_output, fifo_Q_output})
);

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(4),
    .FILE_NAME("tb.out")
) out_source
  (
    .clk(out_clk),
    .rst(rst),
    .out_data({out_stream_data_i, out_stream_data_q}),
    .out_valid(out_stream_valid),
    .out_ready(fifo_out_valid),
    .eof()
  );


endmodule
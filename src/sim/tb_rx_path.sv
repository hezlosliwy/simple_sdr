`timescale 1ns / 1ps

module tb_rx_path;

localparam CLK_PERIOD = 20;

logic clk, out_clk;
logic rst = 1'b1;

logic signed [11:0] in_stream_data_i, in_stream_data_q;
logic [23:0] in_stream;
logic [1:0] iq_rot = 0;
logic [7:0] out_stream_data;
logic out_stream_valid;
logic [7:0] out_model_data;
logic out_model_valid;
logic out_model_ready = 0;
logic err;
logic eof1, eof2, eof;
initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

initial begin
  out_clk = 1'b0;
  forever begin
    out_clk = #(CLK_PERIOD/2/8) ~out_clk;
  end
end

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(3),
    .FILE_NAME("data2.bin")//("data2.bin")
) in_source
  (
    .clk(clk),
    .rst(rst),
    .out_data({in_stream_data_i, in_stream_data_q}),
    .out_valid(in_stream_valid),
    .out_ready(in_stream_ready),
    .eof(eof2)
  );

  assign eof = eof2;

  always @(iq_rot, in_stream_data_i, in_stream_data_q) begin
    case (iq_rot)
      2'b00:
        in_stream <= {in_stream_data_i, in_stream_data_q};
      2'b01:
        in_stream <= {~in_stream_data_q, in_stream_data_i};
      2'b10:
        in_stream <= {~in_stream_data_i, ~in_stream_data_q};
      2'b11:
        in_stream <= {in_stream_data_q, ~in_stream_data_i};
    endcase
  end

  logic [23:0] DUT_data;

  fifo_async
  #(
    .WRITE_DATA_WIDTH(24),
    .READ_DATA_WIDTH(24),
    .DATA_DEPTH(16)
  ) cdc_fifo
  (
      .rst(rst),
      .in_clk(clk),
      .in_valid(in_stream_valid),
      .in_ready(in_stream_ready),
      .in_data(in_stream),
      .out_clk(out_clk),
      .out_valid(DUT_valid),
      .out_ready(DUT_ready),
      .out_data(DUT_data)
  );

  RX_path_top DUT(
    .clk(out_clk),
    .rst(rst),
    .out_ready(fifo_ready),
    .out_valid(fifo_valid),
    .out_data(fifo_data),
    .in_valid(DUT_valid),
    .in_data(DUT_data),
    .in_ready(DUT_ready)
  );

stream_resizer
  #(
    .IN_WIDTH(1),
    .OUT_WIDTH(8)
  ) output_stream_resizer (
    .clk(out_clk),
    .rst(rst),
    .in_valid(fifo_valid),
    .in_data(fifo_data),
    .in_ready(fifo_ready),
    .out_valid(out_stream_valid),
    .out_data(out_stream_data),
    .out_ready(1'b1)
);

task automatic process_output();
  while(1) begin
    @(posedge out_clk)
    if(out_stream_valid) begin
      out_model_ready = 1'b1;
      if(out_model_data!=out_stream_data) begin
        $display("Error expected: %h, received: %h", out_model_data, out_stream_data);
        err = 1'b1;
      end
      @(posedge out_clk)
      err = 1'b0;
      out_model_ready = 1'b0;
      break;
    end
    if(eof) break;
  end
endtask

initial begin
  for(int i=0;i<4;i=i+1) begin
    rst = 1'b1;
    repeat(4*16)@(posedge clk);
    rst = 1'b0;
    $display("reset done");
    while(eof==0) begin
      process_output();
    end
    iq_rot <= iq_rot + 1;
  end
  $display("end of test");
  $finish;
end

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(1),
    .FILE_NAME("tb.in")
) out_source
  (
    .clk(out_clk),
    .rst(rst),
    .out_data (out_model_data),
    .out_valid(out_model_valid),
    .out_ready(out_model_ready),
    .eof(eof1)
  );

endmodule
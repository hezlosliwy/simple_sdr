`timescale 1ns / 1ps

module tb_rx_path;

localparam CLK_PERIOD = 20;

logic clk;
logic rst = 1'b1;

logic [15:0] in_stream_data_i, in_stream_data_q;
logic [23:0] in_stream;
logic [1:0] iq_rot = 0;
logic [7:0] out_stream_data;
logic out_stream_valid;
logic [1:0] out_stream;
integer out_cnt = 0;
logic [7:0] out_model_data;
logic out_model_valid;
logic out_model_ready = 0;
logic err;
logic eof1, eof2, eof;
integer out_cnter = 0;
initial begin : system_clock
  clk = 1'b0;
  forever begin
    clk = #(CLK_PERIOD/2) ~clk;
  end
end

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(4),
    .FILE_NAME("tb.out")
) in_source
  (
    .clk(clk),
    .rst(rst),
    .out_data({in_stream_data_i, in_stream_data_q}),
    .out_valid(in_stream_valid),
    .out_ready(in_stream_ready),
    .eof(eof2)
  );

  assign eof = eof1 | eof2;

  always @(iq_rot, in_stream_data_i, in_stream_data_q) begin
    case (iq_rot)
      2'b00:
        in_stream <= {in_stream_data_i[13:2], in_stream_data_q[13:2]};
      2'b01:
        in_stream <= {~in_stream_data_q[13:2], in_stream_data_i[13:2]};
      2'b10:
        in_stream <= {~in_stream_data_i[13:2], ~in_stream_data_q[13:2]};
      2'b11:
        in_stream <= {in_stream_data_q[13:2], ~in_stream_data_i[13:2]};
    endcase
  end

  RX_path_top DUT(
    .clk(clk),
    .rst(rst),
    .out_valid(out_stream_valid),
    .out_data(out_stream),
    .in_valid(in_stream_valid),
    .in_data(in_stream),
    .in_ready(in_stream_ready)
  );

task automatic process_output();
  out_cnt = 0;
  while(1) begin
    @(posedge clk)
    if(out_stream_valid) begin
      out_stream_data = {out_stream_data[5:0], out_stream};
      out_cnt = out_cnt + 1;
      if(out_cnt == 4) begin
        out_model_ready = 1'b1;
        if(out_model_data!=out_stream_data) begin
          $display("Error expected: %h, received: %h", out_model_data, out_stream_data);
          err = 1'b1;
        end
        @(posedge clk)
        err = 1'b0;
        out_model_ready = 1'b0;
        break;
      end
    end
    if(eof) break;
  end
endtask

initial begin
  for(int i=0;i<4;i=i+1) begin
    rst = 1'b1;
    out_cnt = 0;
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

always @(posedge clk) begin
  if(out_model_valid & out_model_ready) out_cnter <= out_cnter + 1;
end

axis_fsource #(
    .DATA_WIDTH_IN_BYTES(1),
    .FILE_NAME("tb.in")
) out_source
  (
    .clk(clk),
    .rst(rst),
    .out_data (out_model_data),
    .out_valid(out_model_valid),
    .out_ready(out_model_ready),
    .eof(eof1)
  );

endmodule
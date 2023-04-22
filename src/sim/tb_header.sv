`timescale 1ns / 1ps

module tb_header ();

logic clk = 1'b1;
logic rst;
logic in_valid;
logic [11:0] in_i, in_q;
logic in_ready;
logic out_valid;
logic [11:0] out_i, out_q;
logic out_ready;
integer out_data_cnt = 0;

initial begin
    forever clk = #10 ~clk;
end

logic [14:0] data_i = '0;

task automatic data_gen();
    in_i = 12'd300;
    in_q = 12'd300;
    in_valid = 1'b1;
    for(int i=0; i < 10; i=i+1) begin
        if(in_ready) begin
            in_i = ~in_i;
            in_q = ~in_q;
        end
        out_ready <= $random();
        @(negedge clk);
    end
endtask

initial begin : main
    @(posedge clk);
    rst = 1'b1;
    @(negedge clk);
    rst = 1'b0;
    forever begin 
        data_gen();
    end
end

always @(posedge clk) begin
    if(out_ready & out_valid) out_data_cnt <= out_data_cnt + 1;
end

header DUT(
    .clk(clk),
    .rst(rst),
    .in_valid(in_valid),
    .in_i(in_i),
    .in_q(in_q),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .out_i(out_i),
    .out_q(out_q),
    .out_ready(out_ready)
  );

endmodule
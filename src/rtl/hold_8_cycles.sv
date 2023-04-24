
module hold_8_cycles (
  input wire clk,
  input wire rst,
  input wire [11:0] i_I,
  input wire [11:0] i_Q,
  input wire i_valid,

  input wire i_out_ready,
  output reg o_ready_for_input,
  output reg o_valid,
  output reg signed [11:0] o_I,
  output reg signed [11:0] o_Q
);

logic [2:0] cnt;

always@(posedge clk) begin
  if (rst) begin
    o_I <= '0;
    o_Q <= '0;
    cnt <= '0;
    o_valid <= 1'b0;
    o_ready_for_input <= 1'b0;
  end
  else begin
    o_valid <= 1'b0;
    o_ready_for_input <= 1'b1;
    if (i_valid == 1'b1 && cnt == 3'b0 && i_out_ready == 1'b1) begin
      o_I <= i_I;
      o_Q <= i_Q;
      o_valid <= 1'b1;
      cnt <= cnt + 1;
    end
    else if (cnt != 3'b0) begin
      o_ready_for_input <= 1'b0;
      cnt <= cnt + 1;
      o_valid <= 1'b1;
    end
  end
end

endmodule
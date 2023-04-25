
module hold_8_cycles (
  input wire clk,
  input wire rst,

  output wire in_ready,
  input wire [11:0] in_i,
  input wire [11:0] in_q,
  input wire in_valid,

  input wire out_ready,
  output reg out_valid,
  output reg signed [11:0] out_i,
  output reg signed [11:0] out_q
);

logic [2:0] cnt;


assign in_ready = (cnt == 3'b0) ? 1'b1 : 1'b0; 

always@(posedge clk) begin
  if (rst) begin
    out_i <= '0;
    out_q <= '0;
    cnt <= '0;
    out_valid <= 1'b0;
  end
  else begin
    if (in_valid & in_ready) begin
      out_i <= in_i;
      out_q <= in_q;
      out_valid <= 1'b1;
    end
    else if(in_ready) begin
      out_valid <= 1'b0;
    end

    if(out_valid & out_ready) begin
      cnt <= cnt + 1;
    end
  end
end

endmodule
module qpsk_mod(
  input wire clk,
  input wire rst_n,
  input wire in_i,
  input wire in_q,
  input wire in_valid,
  output reg in_ready,

  input wire out_ready,
  output reg out_valid,
  output reg signed [11:0] out_i,
  output reg signed [11:0] out_q
);

const logic [11:0] ampl = 12'd1447;

always@(posedge clk) begin
  if (~rst_n) begin 
    out_i <= 12'b0;
    out_q <= 12'b0;
    out_valid <= 1'b0;
  end
  else begin 
    if (in_valid & in_ready) begin
      out_valid <= 1'b1;
      if ({in_i, in_q} == 2'b01) begin
        out_i <= ampl;
        out_q <= -ampl;
      end
      else if ({in_i, in_q} == 2'b10) begin
        out_i <= -ampl;
        out_q <= ampl;
      end
      else if ({in_i, in_q} == 2'b11) begin
        out_i <= -ampl;
        out_q <= -ampl;
      end
      else if ({in_i, in_q} == 2'b00) begin
        out_i <= ampl;
        out_q <= ampl;
      end
    end
    else if(out_ready)out_valid <= 0;
  end
end

assign in_ready = ~out_valid | out_ready;

endmodule
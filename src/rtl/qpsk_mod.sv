module qpsk_mod(
  input wire clk,
  input wire rst_n,
  input wire i_I,
  input wire i_Q,
  input wire i_valid,

  input wire i_out_ready,
  output reg o_ready_for_input,
  output reg o_valid,
  output reg signed [11:0] o_I,
  output reg signed [11:0] o_Q
);

const logic [11:0] ampl = 12'd1447;

always@(posedge clk or negedge rst_n) begin
  if (!rst_n) begin 
    o_I <= 12'b0;
    o_Q <= 12'b0;
    o_valid <= 1'b0;
  end
  else begin 
    if (i_valid) begin
      o_valid <= 1'b1;
      if ({i_I, i_Q} == 2'b01) begin
        o_I <= ampl;
        o_Q <= -ampl;
      end
      else if ({i_I, i_Q} == 2'b10) begin
        o_I <= -ampl;
        o_Q <= ampl;
      end
      else if ({i_I, i_Q} == 2'b11) begin
        o_I <= -ampl;
        o_Q <= -ampl;
      end
      else if ({i_I, i_Q} == 2'b00) begin
        o_I <= ampl;
        o_Q <= ampl;
      end
    end
    else o_valid <= 1'b0;
  end
end

assign o_ready_for_input = rst_n & i_out_ready;

endmodule
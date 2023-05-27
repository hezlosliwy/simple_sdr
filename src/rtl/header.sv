
module header (
    input wire clk,
    input wire rst,
    input wire in_valid,
    input wire[11:0] in_i,
    input wire[11:0] in_q,
    output wire in_ready,
    output reg out_valid,
    output reg[11:0] out_i,
    output reg[11:0] out_q,
    input wire out_ready
  );

  typedef enum   { ST_IDLE, ST_SOF, ST_PAYLOAD } t_header_state;
  t_header_state header_state;

  logic [4:0] sof_cnt;
  logic [7:0] payload_cnt;

  const logic [11:0] BPSK_AMP = 12'd1447;

  const logic [0:25] SOF = 26'b01100011010010111010000010; // 0x18D2E82
  logic bpsk_bit;

  assign in_ready = (header_state==ST_PAYLOAD & (out_ready | (~out_valid)));

  always @(posedge clk)
  begin
    if(rst) begin
      header_state <= ST_IDLE;
      bpsk_bit <= 1'b0;
      sof_cnt <= 5'b0;
      payload_cnt <= 8'b0;
      out_valid <= 1'b0;
    end
    else begin
      case (header_state)
        ST_IDLE: begin
          if(in_valid) header_state <= ST_SOF;
          else header_state <= ST_IDLE;
        end
        ST_SOF: begin // pi/2 bpsk
          if(out_ready) begin
            sof_cnt <= sof_cnt + 1;
            bpsk_bit <= ~bpsk_bit;
            if(sof_cnt == 5'd25)
            begin
              sof_cnt <= 5'b0;
              header_state <= ST_PAYLOAD;
            end
            out_valid <= 1'b1;
          end
        end
        ST_PAYLOAD: begin
          if(in_valid & in_ready) begin
            payload_cnt <= payload_cnt + 1;
            if(payload_cnt == 8'd62)
            begin
              payload_cnt <= 8'b0;
              header_state <= in_valid ? ST_SOF : ST_IDLE;
            end
            out_valid <= 1'b1;
          end
          else if(out_ready) begin
            out_valid <= 1'b0;
          end
        end
      endcase
    end
  end

  always @(posedge clk) begin
    case (header_state)
      ST_IDLE: begin
        out_i <= 12'b0;
        out_q <= 12'b0;
      end
      ST_SOF: begin
        if(out_ready) begin
          if(bpsk_bit == 0) begin
            out_i <= SOF[sof_cnt] ? -BPSK_AMP : BPSK_AMP;
            out_q <= SOF[sof_cnt] ? -BPSK_AMP : BPSK_AMP;
          end
          else begin
            out_i <= SOF[sof_cnt] ?  BPSK_AMP : -BPSK_AMP;
            out_q <= SOF[sof_cnt] ? -BPSK_AMP :  BPSK_AMP;
          end
        end
      end
      ST_PAYLOAD: begin
        if(in_ready & in_valid) begin
          out_i <= in_i;
          out_q <= in_q;
        end
      end
    endcase
  end

endmodule

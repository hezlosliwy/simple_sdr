`timescale 1ns / 1ps

module physical_receiver(
    input wire clk,
    input wire rst,
    input wire in_valid,
    input wire [23:0] in_data,
    output wire in_ready,
    (* MARK_DEBUG = "TRUE" *)output reg [1:0] out_data,
    (* MARK_DEBUG = "TRUE" *)output reg out_valid
  );

  logic signed [11:0] in_data_store_i [2:0];
  logic signed [11:0] in_data_store_q [2:0];
  (* MARK_DEBUG = "TRUE" *)logic unsigned [2:0] phase_cnt;
  (* MARK_DEBUG = "TRUE" *)logic unsigned [2:0] phase;
  logic unsigned [2:0] phase_sum;
  (* MARK_DEBUG = "TRUE" *)logic signed [22:0] gardner_mertic_i;
  (* MARK_DEBUG = "TRUE" *)logic signed [22:0] gardner_mertic_q;
  (* MARK_DEBUG = "TRUE" *)logic update_phase;
  logic signed [4:0] update_value;
  logic unsigned [5:0] update_cnt;

  logic signed [1:0] sample_i, sample_i_prev; //sample_i_mux, 
  logic signed [1:0] sample_q, sample_q_prev; //sample_q_mux, 
  logic signed [3:0] diff_data_i, diff_data_q;

  (* MARK_DEBUG = "TRUE" *)logic signed [13:0] gardner_mertic_sum;
  (* MARK_DEBUG = "TRUE" *)logic signed [13:7] gardner_mertic_sum_msbs;
  logic [2:0] space_cnt;

  (* MARK_DEBUG = "TRUE" *)logic [12:0] sof_dist_cnt;

  logic [24:0] sof_reg, xor_sof;
  logic [25:0] xor_sof_i, xor_sof_q;
  const logic [24:0] DIFF_SOF = 25'h14bb9c3;

  const logic [25:0] SOF_I = 26'h3278428;
  const logic [25:0] SOF_Q = 26'h272d17d;

  (* MARK_DEBUG = "TRUE" *)logic found_sof;

  logic [5:0] correl_cnt, correl_cnt_swap;
  (* MARK_DEBUG = "TRUE" *)logic [5:0] rot_cnt_i, rot_cnt_i_not;
  (* MARK_DEBUG = "TRUE" *)logic [5:0] rot_cnt_q, rot_cnt_q_not;

  logic [25:0] sof_i_reg;

  logic [5:0] frame_cnt;

  logic found_sof_int;

  (* MARK_DEBUG = "TRUE" *)logic [1:0] rot;

  assign in_ready = ~rst;

  always @(posedge clk) begin
    if (rst) begin
      for(int i = 0;i<3;i=i+1) begin
        in_data_store_i[i] <= 0;
        in_data_store_q[i] <= 0;
      end
      sof_dist_cnt <= 0;
    end
    else begin
      if(found_sof) sof_dist_cnt <= 0;
      else sof_dist_cnt <= sof_dist_cnt + 1;

      if(in_valid) begin
        in_data_store_q[0] <= in_data[11:0];
        in_data_store_i[0] <= in_data[23:12];
        for(int i = 1;i<3;i=i+1) begin
          in_data_store_i[i] <= in_data_store_i[i-1];
          in_data_store_q[i] <= in_data_store_q[i-1];
        end
      end
    end
  end

  assign phase_sum = (phase_cnt+phase)%8;
  assign gardner_mertic_sum_msbs = gardner_mertic_sum[13:7];

  always @(posedge clk) begin
    if(rst) begin
      phase <= 0;
      update_phase <= 0;
      phase_cnt <= 0;
      gardner_mertic_i <= 0;
      gardner_mertic_q <= 0;
      update_value <= 0;
      update_cnt <= 0;
      gardner_mertic_sum <= 0;
      sample_i <= 0;
      sample_q <= 0;
      sample_i_prev <= 0;
      sample_q_prev <= 0;
    end
    else if(in_valid) begin
      phase_cnt <= phase_cnt + 1;
      if(phase_sum == 0) begin
        found_sof_int <= found_sof;
        sample_i <= (~in_data_store_i[1][11]) ? 1 : -1;
        sample_q <= (~in_data_store_q[1][11]) ? 1 : -1;
        sample_i_prev <= sample_i;
        sample_q_prev <= sample_q;
        gardner_mertic_i <= (in_data_store_i[0]-in_data_store_i[2])*in_data_store_i[1];
        gardner_mertic_q <= (in_data_store_q[0]-in_data_store_q[2])*in_data_store_q[1];
        update_phase <= 1'b1;
      end
      else update_phase <= 1'b0;

      if(update_phase) begin
        update_cnt <= update_cnt + 1;
        if(update_cnt == 7) begin
          if(gardner_mertic_sum_msbs < -1) phase <= phase + 1;
          else if(gardner_mertic_sum_msbs > 0) phase <= phase - 1;
          update_cnt <= 0;
          update_value <= 0;
          gardner_mertic_sum <= 0;
        end
        else begin
          gardner_mertic_sum <= gardner_mertic_sum + (gardner_mertic_i>>>9) + (gardner_mertic_q>>>9);
        end
      end
    end
  end

  assign diff_data_i = sample_i*sample_i_prev - sample_q*sample_q_prev;
  assign diff_data_q = -sample_i*sample_q_prev + sample_q*sample_i_prev;

  always @(posedge clk) begin
    if(rst) begin
      sof_reg <= 25'b0;
      correl_cnt <= 0;
      rot_cnt_i <= 0;
      rot_cnt_q <= 0;
      found_sof <= 1'b0;
      sof_i_reg <= 0;
      rot <= 2'b0;
    end
    else begin
      if(phase_sum == 1 & in_valid) begin
        sof_reg <= {sof_reg[23:0], (diff_data_i > 0) ? 1'b1 : 1'b0};
        sof_i_reg <= {sof_i_reg[24:0],(in_data_store_i[1] > 0) ? 1'b1 : 1'b0};
        if(rot_cnt_i > 20) rot <= 2'b00;
        else if(rot_cnt_q > 20) rot <= 2'b01;
        else if(rot_cnt_i < 5) rot <= 2'b10;
        else if(rot_cnt_q < 5) rot <= 2'b11;
        else rot <= rot;
      end

      correl_cnt = 0;
      rot_cnt_i = 0;
      rot_cnt_q = 0;
      for(int i=0;i<25;i=i+1) begin
        correl_cnt = xor_sof[i]==1'b0 ? (correl_cnt + 1) : correl_cnt;
        rot_cnt_i = xor_sof_i[i]==1'b0 ? (rot_cnt_i + 1) : rot_cnt_i;
        rot_cnt_q = xor_sof_q[i]==1'b0 ? (rot_cnt_q + 1) : rot_cnt_q;
      end

      if(correl_cnt > 20) begin
        found_sof <= 1'b1;
      end
      else if(correl_cnt < 5) begin
        found_sof <= 1'b1;
      end
      else found_sof <= 1'b0;
    end
  end

  assign xor_sof = sof_reg^DIFF_SOF;
  assign xor_sof_i = sof_i_reg^SOF_I;
  assign xor_sof_q = sof_i_reg^SOF_Q;

  const logic [1:0] QPSK_ARR [0:3] = {2'b00, 2'b10, 2'b11, 2'b01}; 

  always @(posedge clk) begin
    if(rst) begin
      frame_cnt <= 0;
      out_valid <= 1'b0;
      space_cnt <= 2'b0;
    end
    else begin
      if(space_cnt>0 & in_valid) space_cnt<=space_cnt-1;
      else if(phase_sum < 3) space_cnt <= 2'b0;
      else space_cnt <= 3'b111;

      if(phase_sum > 2 & (found_sof_int | frame_cnt != 0) & space_cnt==0) begin
        out_valid <= 1'b1;
        if(frame_cnt < 62) frame_cnt <= frame_cnt + 1;
        else frame_cnt <= 0;
        if(~sample_i[1]) begin //sample_i>0
          if(~sample_q[1]) out_data <= QPSK_ARR[rot];        
          else out_data <= QPSK_ARR[(3+rot)%4];
        end
        else begin
          if(~sample_q[1]) out_data <= QPSK_ARR[(1+rot)%4];        
          else out_data <= QPSK_ARR[(2+rot)%4];
        end
      end
      else out_valid <= 1'b0;
    end
  end

endmodule

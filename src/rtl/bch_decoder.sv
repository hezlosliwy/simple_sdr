`timescale 1ns/1ps


module bch_decoder (
    input  wire clk,
    input  wire rst,
    input  wire in_valid,
    input  wire in_data,
    output wire in_ready,
    output wire out_valid,
    output wire out_data,
    input  wire out_ready
  );
  function logic[5:0] mult_by_a(logic[5:0] a); // a * x mod x6+x+1
    return {a[4:0],1'b0}^{4'b0, a[5], a[5]};
  endfunction

  function logic[5:0] mult(logic[5:0] a, b); // a**2 mod x6+x+1
    logic[10:0] res;
    res = 11'b0;
    for(int i=0; i<6;i=i+1)
    begin
      res = b[i] ? (res ^ ({6'b0,a}<<i) ): res;
    end
    // $display("Mult: %b", res);
    for(int i=0; i<5;i=i+1)
    begin //modulo division operation
      res = res[10-i] ? res ^ (11'b10000110000>>i) : res;
    end
    // $display("Div: %b", res);
    return res[5:0];
  endfunction

  function logic[5:0] inverse(logic[5:0] a); // a**-1
    logic[5:0] inv_table [0:63] = {
        6'b000000, 6'b000001, 6'b100001, 6'b111110, 6'b110001, 6'b101011,
        6'b011111, 6'b101100, 6'b111001, 6'b100101, 6'b110100, 6'b011100,
        6'b101110, 6'b101000, 6'b010110, 6'b011001, 6'b111101, 6'b110110,
        6'b110011, 6'b100111, 6'b011010, 6'b100011, 6'b001110, 6'b011000,
        6'b010111, 6'b001111, 6'b010100, 6'b100010, 6'b001011, 6'b110101,
        6'b101101, 6'b000110, 6'b111111, 6'b000010, 6'b011011, 6'b010101,
        6'b111000, 6'b001001, 6'b110010, 6'b010011, 6'b001101, 6'b101111,
        6'b110000, 6'b000101, 6'b000111, 6'b011110, 6'b001100, 6'b101001,
        6'b101010, 6'b000100, 6'b100110, 6'b010010, 6'b001010, 6'b011101,
        6'b010001, 6'b111100, 6'b100100, 6'b001000, 6'b111011, 6'b111010,
        6'b110111, 6'b010000, 6'b000011, 6'b100000
    };
    return inv_table[a];
  endfunction

  typedef enum { ST_IDLE, ST_SYNDROME, ST_EDP, ST_FIND_ERRORS, ST_UNLOAD } t_bch_state;
  t_bch_state bch_state;

  logic [5:0] S1, S3;
  logic [5:0] a1, a3;
  logic [5:0] sig1, sig2;
  logic [5:0] e, err_code;

  logic [5:0] syndrome_cnt;
  logic out_valid_int;
  logic [5:0] err_cnt;
  logic [62:0] data_reg;
  assign err_found = (err_code==1);
  assign out_data = data_reg[62] ^ (err_code==1);
  assign in_ready = (bch_state == ST_SYNDROME);
  assign out_valid =  (bch_state == ST_FIND_ERRORS) | (bch_state == ST_UNLOAD);
  assign err_code = mult(sig1,e) ^ mult(sig2,mult(e,e));

  always @(posedge clk) begin
    if(rst) begin
      a1 <= 6'b000001;
      a3 <= 6'b000001;
      S1 <= 6'b000000;
      S3 <= 6'b000000;
      syndrome_cnt <= 6'b0;
      data_reg <= 63'b0;
      err_cnt <= 0;
    end
    else begin
      case (bch_state)
        ST_IDLE:
          if(in_valid) begin
            bch_state <= ST_SYNDROME;
            a1 <= inverse(6'b10);
            a3 <= inverse(6'b1000);
            S1 <= 6'b000000;
            S3 <= 6'b000000;
          end
        ST_SYNDROME: begin
          if(in_valid) begin
            data_reg <= {data_reg[61:0], in_data};
            S1 <= in_data ? (S1 ^ a1) : S1;
            S3 <= in_data ? (S3 ^ a3) : S3;
            a1 = mult(a1,inverse(6'b10));
            a3 = mult(a3,inverse(6'b1000));
            syndrome_cnt <= syndrome_cnt + 6'b1;
            if(syndrome_cnt==6'd62) begin
              syndrome_cnt <= 6'b0;
              bch_state <= ST_EDP;
            end
          end
        end
        ST_EDP: begin
          sig1 <= S1;
          sig2 <= mult(S1,S1) ^ mult(S3,inverse(S1));
          if(S1!=0 & S3!=0) begin
            bch_state <= ST_FIND_ERRORS;
            e <= 6'b10;
          end else begin
            bch_state <= ST_UNLOAD;
          end
          out_valid_int <= 1'b1;
        end
        ST_FIND_ERRORS: begin
          if(out_ready) begin
            syndrome_cnt <= syndrome_cnt + 6'b1;
            if(syndrome_cnt==6'd62) begin
              syndrome_cnt <= 6'b0;
              bch_state <= ST_IDLE;
            end
            // if(err_found) begin
            //   $display("Error found %d", 62-syndrome_cnt);
            // end
            e <= mult(e, 6'b000010);
            data_reg <= {data_reg[61:0], 1'b0};
          end
        end
        ST_UNLOAD: begin
          if(out_ready) begin
            syndrome_cnt <= syndrome_cnt + 6'b1;
            data_reg <= {data_reg[61:0], 1'b0};
            if(syndrome_cnt==6'd62) begin
              out_valid_int <= 1'b0;
              syndrome_cnt <= 6'b0;
              bch_state <= ST_IDLE;
            end
          end
        end
      endcase
    end
  end

endmodule

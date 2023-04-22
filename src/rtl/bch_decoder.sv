`timescale 1ns/1ps


module bch_decoder (
    input  wire [62:0] in_data,
    output reg         out_data
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

  logic [5:0] S1, S3;
  logic [5:0] a1, a3;
  logic [5:0] sig1, sig2;
  logic [5:0] e, err_code;

  always @(in_data) begin
    a1 = 6'b000001;
    a3 = 6'b000001;
    S1 = 6'b000000;
    S3 = 6'b000000;
    for(int i = 0;i<63;i=i+1)
    begin
      S1 = in_data[i] ? S1 ^ a1 : S1;
      S3 = in_data[i] ? S3 ^ a3 : S3;
      a1 = mult_by_a(a1);
      a3 = mult_by_a(mult_by_a(mult_by_a(a3)));
    end
    sig1 = S1;
    sig2 = mult(S1,S1) ^ mult(S3,inverse(S1));

    e=6'b1;
    for(int i = 0; i<63;i=i+1)
    begin
      err_code = mult(sig1,e) ^ mult(sig2,mult(e,e));
      if(err_code==6'b1) begin
        $display("Error on %d, %6b", i, err_code);
      end
      e = mult(e, 6'b100001);
    end
  end

endmodule

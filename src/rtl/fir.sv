
// // Signed adder

// module signed_adder
// #(parameter WIDTH=16)
// (
// 	input signed [WIDTH-1:0] dataa,
// 	input signed [WIDTH-1:0] datab,
// 	input cin,
// 	output [WIDTH:0] result
// );

// assign result = dataa + datab + cin;

// endmodule

// // Quartus Prime Verilog Template
// // Signed multiply

// module signed_multiply
// #(parameter WIDTH=16)
// (
// 	input signed [WIDTH-1:0] dataa,
// 	input signed [WIDTH-1:0] datab,
// 	output [2*WIDTH-1:0] dataout
// );

// assign dataout = dataa * datab;

// endmodule


// module register
// #(parameter WIDTH=16)
// (
// 	input signed [WIDTH-1:0] dataa,
// 	input clk,
// 	input reset_n,
// 	output logic signed [WIDTH-1:0] dataout
// );

// always_ff@ (posedge clk) begin
// 	if(reset_n == 1'b0) dataout <= 0;		
// 	else dataout <= dataa;
// end

// endmodule


// module fir
// #(parameter WIDTH=12,
//   parameter FIR_TAP=64
// )
// (
// 	// input logic clk, input logic reset_n,
// 	// input logic signed[WIDTH-1:0] d,
// 	// output logic signed[WIDTH-1:0] q
//   input wire clk,
//   input wire rst,
//   input wire in_valid,
//   input logic signed [WIDTH-1:0] in_data_i,
//   // input logic signed [11:0] in_data_q,
//   output wire in_ready,
//   output reg out_valid,
//   output logic signed [WIDTH-1:0] out_data_i,
//   // output logic signed [11:0] out_data_q,
//   input wire out_ready
// );
			  
// logic signed[WIDTH-1:0] delay[FIR_TAP-1:0];
// logic signed[2*WIDTH-1:0] prod;
// logic signed[WIDTH:0] sum;

// logic [5:0] i;
			  
// const logic signed [WIDTH-1:0] lut_rom[0:FIR_TAP-1] = {
//   12'd0, -12'd3, -12'd9, -12'd15, -12'd21, -12'd24, -12'd23, -12'd15, 
//   12'd0, 12'd21, 12'd46, 12'd69, 12'd86, 12'd92, 12'd80, 12'd50,
//   12'd0, -12'd64, -12'd135, -12'd200, -12'd246, -12'd259, -12'd227, -12'd142,
//   12'd0, 12'd193, 12'd426, 12'd682, 12'd938, 12'd1170, 12'd1355, 12'd1475,
//   12'd1516, 12'd1475, 12'd1355, 12'd1170, 12'd938, 12'd682, 12'd426, 12'd193,
//   12'd0, -12'd142, -12'd227, -12'd259, -12'd246, -12'd200, -12'd135, -12'd64,
//   12'd0, 12'd50, 12'd80, 12'd92, 12'd86, 12'd69, 12'd46, 12'd21,
//   12'd0, -12'd15, -12'd23, -12'd24, -12'd21, -12'd15, -12'd9, -12'd3
// };

// logic signed[WIDTH-1:0] coefficient;
			  
// assign delay[0] = in_data_i;
					
// genvar n;
// generate
// 	for(n = 1; n < FIR_TAP; n = n + 1) begin
//     register reg_inst0(.dataa(delay[n-1]),
//                   .clk(clk),
//                   .reset_n(~rst),
//                   .dataout(delay[n]));
//   end
// endgenerate

// always@(posedge clk) begin
//   if(rst) out_valid <= 1'b0;
//   else begin
//     if(in_valid & in_ready) out_valid <= 1'b1;
//   end
// end

// assign in_ready = ~out_valid | out_ready;
			 
// always@(posedge clk) begin
//   if(rst) begin
//     i <= '0;
//     coefficient <= '0;
//   end
//   else begin
//     if(in_valid & in_ready) begin
//       // for(int i = 0; i <= FIR_TAP - 1; i = i + 1) begin
//       coefficient <= lut_rom[i];
//       i <= i + 1;
//     end
//   end
// end
					
// signed_multiply #(.WIDTH(WIDTH)) inst(.dataa(delay[FIR_TAP-1]),
// 				        .datab(coefficient),
// 							  .dataout(prod));
				
// signed_adder #(.WIDTH(WIDTH)) adder_fir(.dataa($signed(prod[2 * WIDTH-2:WIDTH-1])),
// 							  .datab(out_data_i),
// 							  .cin(0),
// 							  .result(sum));

// register #(.WIDTH(WIDTH)) reg_inst1(.dataa($signed(sum[WIDTH:1])),
// 						 .clk(clk),
// 						 .reset_n(~rst),
// 						 .dataout(out_data_i));

// endmodule

module fir (
    input wire clk,
    input wire rst,
    input wire in_valid,
    input logic signed [11:0] in_data_i,
    input logic signed [11:0] in_data_q,
    output wire in_ready,
    output reg out_valid,
    output logic signed [11:0] out_data_i,
    output logic signed [11:0] out_data_q,
    input wire out_ready
  );

  logic signed [25:0] regs_i [63:0];
  logic signed [25:0] regs_q [63:0];

  // real coefs [0:63] = {
  //   -6.518263187043542e-19, -7.986557578197472e-04, -0.002095202987291, -0.003667107969085,
  //   -0.005116643415385, -0.005928729916395, -0.005574799504880, -0.003647417401953,
  //   4.178988515525191e-18, 0.005140327380087, 0.011118819256345, 0.016883231769783,
  //   0.021109413050609, 0.022415483902514, 0.019637994970885, 0.012126229259175,
  //   -8.833912267524514e-18, -0.015685124676703, -0.032911842822594, -0.048841462160068,
  //   -0.060120550944356, -0.063323725395885, -0.055474603586424, -0.034566931655455,
  //   1.284346534816169e-17, 0.047150897274960, 0.104087211505337, 0.166488826877401,
  //   0.228951469309608, 0.285607773393619, 0.330847986488195, 0.360037028336954,
  //   0.370121787174637, 0.360037028336954, 0.330847986488195, 0.285607773393619,
  //   0.228951469309608, 0.166488826877401, 0.104087211505337, 0.047150897274960,
  //   1.284346534816169e-17, -0.034566931655455, -0.055474603586424, -0.063323725395885,
  //   -0.060120550944356, -0.048841462160068, -0.032911842822594, -0.015685124676703,
  //   -8.833912267524514e-18, 0.012126229259175, 0.019637994970885, 0.022415483902514, 
  //   0.021109413050609, 0.016883231769783, 0.011118819256345, 0.005140327380087,
  //   4.178988515525191e-18, -0.003647417401953, -0.005574799504880, -0.005928729916395,
  //   -0.005116643415385, -0.003667107969085, -0.002095202987291, -7.986557578197472e-04
  // };

  // const logic signed [12:0] coefs [0:63] = {
  //   13'd0, -13'd7, -13'd17, -13'd30, -13'd42, -13'd49, -13'd46, -13'd30, 
  //   13'd0, 13'd42, 13'd91, 13'd138, 13'd173, 13'd184, 13'd161, 13'd99,
  //   13'd0, -13'd128, -13'd270, -13'd400, -13'd493, -13'd519, -13'd454, -13'd283,
  //   13'd0, 13'd386, 13'd853, 13'd1364, 13'd1876, 13'd2340, 13'd2710, 13'd2949,
  //   13'd3032, 13'd2949, 13'd2710, 13'd2340, 13'd1876, 13'd1364, 13'd853, 13'd386,
  //   13'd0, -13'd283, -13'd454, -13'd519, -13'd493, -13'd400, -13'd270, -13'd128,
  //   13'd0, 13'd99, 13'd161, 13'd184, 13'd173, 13'd138, 13'd91, 13'd42,
  //   13'd0, -13'd30, -13'd46, -13'd49, -13'd42, -13'd30, -13'd17, -13'd7
  // };

  const logic signed [11:0] coefs [0:63] = {
    12'd0, -12'd3, -12'd9, -12'd15, -12'd21, -12'd24, -12'd23, -12'd15, 
    12'd0, 12'd21, 12'd46, 12'd69, 12'd86, 12'd92, 12'd80, 12'd50,
    12'd0, -12'd64, -12'd135, -12'd200, -12'd246, -12'd259, -12'd227, -12'd142,
    12'd0, 12'd193, 12'd426, 12'd682, 12'd938, 12'd1170, 12'd1355, 12'd1475,
    12'd1516, 12'd1475, 12'd1355, 12'd1170, 12'd938, 12'd682, 12'd426, 12'd193,
    12'd0, -12'd142, -12'd227, -12'd259, -12'd246, -12'd200, -12'd135, -12'd64,
    12'd0, 12'd50, 12'd80, 12'd92, 12'd86, 12'd69, 12'd46, 12'd21,
    12'd0, -12'd15, -12'd23, -12'd24, -12'd21, -12'd15, -12'd9, -12'd3
  };

  // genvar n;
  // generate
  //   for(n = 1; n < 64; n = n+1) begin
  //     register reg_inst_i_0(.dataa(regs_i[n-1]),
	// 								 .clk(clk),
	// 								 .reset_n(~rst),
	// 								 .dataout(regs_i[n]));
  //     register reg_inst_q_0(.dataa(regs_q[n-1]),
	// 								 .clk(clk),
	// 								 .reset_n(~rst),
	// 								 .dataout(regs_q[n]));
  //   end
  // endgenerate

  // always_ff@(posedge clk)
  //   for(i = 0; i <= 64 - 1; i = i+ 1) begin
  //     coefficient  <= lut_rom[i];
  //   end

  // signed_multiply inst(.dataa(delay[63]),
  //                     .datab(coefficient),
  //                     .dataout(prod));
				
  // signed_adder adder_fir(.dataa($signed(prod[62:63])),
  //                       .datab(q),
  //                       .cin(0),
  //                       .result(sum));

  // register reg_inst1(.dataa($signed(sum[13:1])),
	// 					 .clk(clk),
	// 					 .reset_n(~rst),
	// 					 .dataout(q));

  always @(posedge clk) begin
    if(rst) begin
      out_valid <= 1'b0;
      for(int i =0;i<64;i=i+1) begin
        regs_i[i] <= '0;
        regs_q[i] <= '0;
      end
    end
    else begin
      if(in_valid & in_ready) begin
        out_valid <= 1'b1;
        for(int i =0;i<64;i=i+1) begin
          regs_i[i] <= (i>0) ? (coefs[i]*in_data_i + regs_i[i-1]) : coefs[i]*in_data_i;
          regs_q[i] <= (i>0) ? (coefs[i]*in_data_q + regs_q[i-1]) : coefs[i]*in_data_q;
        end
      end
    end
  end

  assign in_ready = ~out_valid | out_ready;

  assign out_data_i = regs_i[63] >>> 14;
  assign out_data_q = regs_q[63] >>> 14;

endmodule

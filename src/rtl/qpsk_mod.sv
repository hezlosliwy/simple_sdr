module qpsk_mod(
    input logic clk,
    input logic rst_n,
    input logic s_clk,
    input logic i_I,
    input logic i_Q,
    input logic i_valid,

    output logic o_ready,
    output logic [11:0] o_I,
    output logic [11:0] o_Q
);

reg [11:0] sine_values [64] = {
    12'h400,12'h464,12'h4c8,12'h529,12'h588,12'h5e3,12'h639,12'h68a,
    12'h6d4,12'h718,12'h753,12'h787,12'h7b2,12'h7d4,12'h7ec,12'h7fb,
    12'h800,12'h7fb,12'h7ec,12'h7d4,12'h7b2,12'h787,12'h753,12'h718,
    12'h6d4,12'h68a,12'h639,12'h5e3,12'h588,12'h529,12'h4c8,12'h464,
    12'h400,12'h39c,12'h338,12'h2d7,12'h278,12'h21d,12'h1c7,12'h176,
    12'h12c,12'he8,12'had,12'h79,12'h4e,12'h2c,12'h14,12'h5,
    12'h0,12'h5,12'h14,12'h2c,12'h4e,12'h79,12'had,12'he8,
    12'h12c,12'h176,12'h1c7,12'h21d,12'h278,12'h2d7,12'h338,12'h39c
};

logic [5:0] tcos, tsin;
logic [5:0] tcos_nxt, tsin_nxt;
logic [1:0] iq_mode;
logic clk_prev, clk_temp;

always_ff @(posedge s_clk or negedge rst_n) begin
    clk_temp <= clk;
    clk_prev <= clk_temp;
    if (!rst_n) begin 
        tsin <= '0;
        tcos <= 32;
    end
    else begin 
        tsin <= tsin_nxt;
        tcos <= tcos_nxt;
    end
end

always_comb begin
    tsin_nxt = tsin+1;
    tcos_nxt = tcos+1;
    if ({i_I, i_Q} == 2'b01 && clk_prev == 1'b0 && clk == 1'b1) begin
        tsin_nxt <= tsin + 16;
        tcos_nxt <= tcos + 16;
    end
    else if ({i_I, i_Q} == 2'b10 && clk_prev == 1'b0 && clk == 1'b1) begin
        tsin_nxt <= tsin + 32;
        tcos_nxt <= tcos + 32;
    end
    else if ({i_I, i_Q} == 2'b11 && clk_prev == 1'b0 && clk == 1'b1) begin
        tsin_nxt <= tsin + 48;
        tcos_nxt <= tcos + 48;
    end
end

assign o_I = sine_values[tcos];
assign o_Q = sine_values[tsin];
assign o_ready = rst_n;

endmodule
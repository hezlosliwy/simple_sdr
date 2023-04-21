module qpsk_mod(
    input logic clk,
    input logic rst_n,
    input logic i_I,
    input logic i_Q,
    input logic i_valid,

    output logic o_ready,
    output logic signed [11:0] o_I,
    output logic signed [11:0] o_Q
);

logic signed [11:0] amplitudes [2] = {12'h5a7, 12'ha59};

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin 
        o_I <= '0;
        o_Q <= '0;
    end
    else begin 
        if ({i_I, i_Q} == 2'b01) begin
            o_I <= amplitudes[0];
            o_Q <= amplitudes[1];
        end
        else if ({i_I, i_Q} == 2'b10) begin
            o_I <= amplitudes[1];
            o_Q <= amplitudes[0];
        end
        else if ({i_I, i_Q} == 2'b11) begin
            o_I <= amplitudes[1];
            o_Q <= amplitudes[1];
        end
        else if ({i_I, i_Q} == 2'b00) begin
            o_I <= amplitudes[0];
            o_Q <= amplitudes[0];
        end
    end
end

assign o_ready = rst_n;

endmodule
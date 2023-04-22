`timescale 1ns/1ps


module tb_bch_decoder ();

    logic[62:0] in_data;
    
    // assign in_data = 63'h7FFFFFFFFFFFFFFF;
    assign in_data = 63'b011011100111100100011110000000011010101000111001110110010111100;
    integer e1, e2;

    logic clk = 0;

initial begin
    forever begin
        clk = #10 ~clk;
    end
end

always @(posedge clk) begin
    e1 = $urandom() % 63;
    e2 = $urandom() % 63;
    $display("Error 1: %d, error 2 %d", e1, e2);
end

bch_decoder DUT(
    .in_data(in_data ^ (1<<e1) ^ (1<<e2)),
    .out_data()
);

endmodule

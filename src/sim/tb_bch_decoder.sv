`timescale 1ns/1ps


module tb_bch_decoder ();

    logic[62:0] in_data, output_data;
    
    // assign in_data = 63'h7FFFFFFFFFFFFFFF;
    integer e1=15, e2 = 58;
    logic rst;
    logic clk = 0;
    integer data_cnt = 0;
    logic out_ready = 0;
    const logic [62:0] correct_data = 63'b100001001010111101101000011010000010010110101010110110000000110;
    assign in_data = correct_data ^ (1<<(e1)) ^ (1<<(e2)); //63'h7FFFFFFFFFFFFFFF
    assign in_valid = ~rst;
initial begin
    forever begin
        clk = #10 ~clk;
    end
end

initial begin
    rst = 1'b1;
    repeat(3) @(posedge clk);
    rst = 1'b0;
end

always @(posedge clk) begin
    out_ready <= 1;//$random();
    if(data_cnt == 62 & ~rst) begin
        e1 <= $urandom() % 63;
        e2 <= $urandom() % 63;
        $display("Error 1: %d, error 2 %d", e1, e2);
    end
    if(in_ready) begin
        data_cnt = (data_cnt + 1) % 63;
    end
    if(out_valid & out_ready) begin
        output_data = {output_data[61:0], out_data};// output_data = {output_data[61:12], out_data, 12'b0};
    end
end

bch_decoder DUT(
    .rst(rst),
    .clk(clk),
    .in_valid(in_valid),
    .in_data(in_data[62-data_cnt]),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .out_data(out_data),
    .out_ready(out_ready)
);

endmodule

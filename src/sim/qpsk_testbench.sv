`timescale 1ns / 1ps

module qpsk_testbench;

localparam CLK_PERIOD = 5;

logic clk;
logic rst_n;
logic i_I, i_Q;
logic [11:0] o_I, o_Q;
logic i_valid;
logic o_ready;
logic o_valid;
logic i_out_ready;

logic [7:0] vdata;

initial begin : system_clock
    clk = 1'b0;
    forever begin
        clk = #(CLK_PERIOD/2) ~clk;
    end
end

logic [14:0] data_i = '0;

task automatic parallel_input(input [15:0] data);
    i_valid = 1'b1;
    for(int i=0; i < ($size(data)); i=i+2) begin
        i_I = data[i];
        i_Q = data[i+1];
        $display("I=%d \tQ=%d",i_I,i_Q);
        @(posedge clk);
    end
    i_out_ready = 1'b0;
    repeat(4) @(posedge clk);
    $finish();
endtask

initial begin : main
    rst_n = 1'b0;
    i_out_ready = 1'b0;
    repeat(2)@(posedge clk);
    rst_n = 1'b1;
    i_out_ready = 1'b1;
    forever begin 
        parallel_input(16'b1110100101111000);
    end
end

// axis_fsource #(
//     .FILE_NAME("qpsk_testv.in"), 
//     .DATA_WIDTH_IN_BYTES(1))
//     rd_file_vector (
//         .rst(~rst_n),
//         .clk(clk),
//         .out_valid(i_valid),
//         .out_ready(o_ready),
//         .out_data(vdata),
//         .eof()
//     );

qpsk_mod u_qpsk_mod (
    .clk        (clk),
    .rst_n      (rst_n),
    .i_I        (i_I),
    .i_Q        (i_Q),
    .i_valid    (i_valid),
    .i_out_ready(i_out_ready),
    .o_ready_for_input(o_ready),
    .o_valid    (o_valid),
    .o_I        (o_I),
    .o_Q        (o_Q)
);

endmodule
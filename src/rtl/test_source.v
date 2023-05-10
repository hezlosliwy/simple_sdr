`timescale 1ns / 1ps

module test_source(
    input wire clk,
    input wire rst,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output reg [1:0] out_data, //i q
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    input wire out_ready,
    //internal input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire [23:0] in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready
    );


    always @(posedge clk) begin
        if(rst) begin
            out_data <= 2'b0;
        end
        else if(out_ready) begin
            out_data <= ~out_data;
        end
        else out_data <= out_data;
    end

    assign out_valid = 1'b1;
    assign in_ready = 1'b1;
endmodule

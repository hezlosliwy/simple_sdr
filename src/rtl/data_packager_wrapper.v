
module data_packager_wrapper(
    input wire clk,
    input wire rst,
    //output stream to fifo
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TVALID" *)
    output wire out_fifo_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TDATA" *)
    output wire [31:0] out_fifo_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TREADY" *)
    input wire out_fifo_ready,
    //input stream from fifo
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TVALID" *)
    input wire in_fifo_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TDATA" *)
    input wire [31:0] in_fifo_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TREADY" *)
    output wire in_fifo_ready,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output wire out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire out_data, //i q
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    input wire out_ready,
    //internal input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready
    );

data_packager my_packager(
    clk,
    rst,
    out_fifo_valid,
    out_fifo_data,
    out_fifo_ready,
    in_fifo_valid,
    in_fifo_data,
    in_fifo_ready,
    out_valid,
    out_data,
    out_ready,
    in_valid,
    in_data,
    in_ready
    );


endmodule
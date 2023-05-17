module width_converter(
    input wire clk,
    input wire rst,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output reg out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output reg [1:0] out_data,
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

    logic out_cnt;

    assign in_ready = (~out_valid | out_ready); //load new data if old is unloaded or no data is stored

    always @(posedge clk) begin
        out_valid <= out_ready ? 1'b0 : out_valid; //if out_ready unload, otherwise hold state
        if(in_valid & in_ready) begin
            out_cnt <= ~out_cnt;
            if(out_cnt == 1'b0) out_data[1] <= in_data;
            else begin
                out_data[0] <= in_data;
                out_valid <= 1'b1;
            end
        end
    end

endmodule

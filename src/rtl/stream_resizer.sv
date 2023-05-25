module stream_resizer
    #(
        parameter IN_WIDTH=8,
        OUT_WIDTH=8
    )
    (
    input wire clk,
    input wire rst,
    //input stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TVALID" *)
    input wire in_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TDATA" *)
    input wire [IN_WIDTH-1:0] in_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_in TREADY" *)
    output wire in_ready,
    //output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output reg out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output wire [OUT_WIDTH-1:0] out_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TREADY" *)
    input wire out_ready
);

  function integer max(integer a, b);
    return (a>b ? a : b);
  endfunction

  parameter DATA_REG_SIZE = max(IN_WIDTH, OUT_WIDTH);

  logic [$clog2(max(IN_WIDTH,OUT_WIDTH))-1:0] data_cnt;
  logic [DATA_REG_SIZE-1:0] data_reg;
  const logic [$clog2(max(IN_WIDTH,OUT_WIDTH))-1:0] RESIZE_RATE = max(IN_WIDTH/OUT_WIDTH, OUT_WIDTH/IN_WIDTH);

  const logic [OUT_WIDTH-1:0] OUT_WIDTH_GND = 0;

  assign in_ready = (
    (data_cnt==0 & out_ready & max(IN_WIDTH, OUT_WIDTH)==IN_WIDTH) |
    (((data_cnt==0 & out_ready) | data_cnt!=0) & max(IN_WIDTH, OUT_WIDTH)==OUT_WIDTH)
    ) & ~rst;
  assign out_data = data_reg[$bits(data_reg)-1:$bits(data_reg)-OUT_WIDTH];


  always @(posedge clk) begin
    if(rst) begin
      data_cnt <= 0;
      out_valid <= 0;
      data_reg <= 0;
    end
    else begin
      if(max(IN_WIDTH, OUT_WIDTH)==OUT_WIDTH) begin
        if(in_valid & in_ready) begin
          data_reg <= {data_reg[$bits(data_reg)-1-IN_WIDTH:0], in_data};
          data_cnt <= (data_cnt!=RESIZE_RATE-1) ? (data_cnt + 1) : 0;
          if(data_cnt==(RESIZE_RATE-1)) out_valid <= 1;
          else out_valid <= 0;
        end
        else if(out_ready) out_valid <= 0;
      end
      else begin
        if((in_valid | data_cnt!=0)&out_ready) begin
          if(out_ready) begin
            data_cnt <= (data_cnt!=RESIZE_RATE-1) ? (data_cnt + 1) : 0;
          end
          if(data_cnt==0) begin
            data_reg <= in_data;
            out_valid <= 1'b1;
          end
          else begin
            data_reg <= {data_reg[$bits(data_reg)-1-OUT_WIDTH:0], OUT_WIDTH_GND};
          end
        end
        else if(out_ready) out_valid <= 0;
      end
    end
  end

endmodule
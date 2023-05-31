`timescale 1ns / 1ps

module data_packager(
    input wire clk,
    input wire rst,
    //output stream to fifo
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TVALID" *)
    output wire out_fifo_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TDATA" *)
    output reg [31:0] out_fifo_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_out TREADY" *)
    input wire out_fifo_ready,
    //input stream from fifo
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TVALID" *)
    input wire in_fifo_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TDATA" *)
    input wire [31:0] in_fifo_data,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 fifo_in TREADY" *)
    output reg in_fifo_ready,
    //internal output stream
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TVALID" *)
    output reg out_valid,
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 axis_out TDATA" *)
    output reg out_data, //i q
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

    (* MARK_DEBUG = "TRUE" *)logic [6:0] frame_cnt;
    (* MARK_DEBUG = "TRUE" *)enum { ST_IDLE, ST_IDLE_HEADER, ST_HEADER, ST_IDLE_PAYLOAD, ST_PAYLOAD } framegen_state;

    logic in_resizer_ready;

    logic fifo_data;

    stream_resizer
    #(
      .IN_WIDTH(32),
      .OUT_WIDTH(1)
    ) input_stream_resizer (
      .clk(clk),
      .rst(rst),
      .in_valid(in_fifo_valid),
      .in_data(in_fifo_data),
      .in_ready(in_fifo_ready),
      .out_valid(fifo_valid),
      .out_data(fifo_data),
      .out_ready(fifo_ready)
  );

  fifo_sync
  #(
    .WRITE_DATA_WIDTH(1),
    .READ_DATA_WIDTH(1),
    .DATA_DEPTH(16),
    .PROG_EMPTY_THRESH(0),
    .PROG_FULL_THRESH(0)
  ) my_fifo_sync
  (
      .rst(rst),
      .clk(clk),
      .in_valid(fifo_valid),
      .in_ready(fifo_ready),
      .in_data(fifo_data),
      .out_valid(in_resizer_valid),
      .out_ready(in_resizer_ready),
      .out_data(in_resizer_data)
  );

    always @(posedge clk) begin : idle_frame_gen
        if(rst) begin
            out_data <= 1'b0;
            frame_cnt <= 0;
            framegen_state <= ST_IDLE;
        end
        else begin
            if(out_ready) begin
                case (framegen_state)
                    ST_IDLE: begin
                        out_valid <= 1'b0;
                        framegen_state <= in_resizer_valid ? ST_HEADER : ST_IDLE_HEADER;
                    end
                    ST_IDLE_HEADER: begin
                        out_valid <= 1'b1;
                        out_data <= 1'b1;
                        frame_cnt <= frame_cnt + 1;
                        if(frame_cnt==5) framegen_state <= ST_IDLE_PAYLOAD;
                    end
                    ST_HEADER: begin
                        out_valid <= 1'b1;
                        out_data <= 1'b0;
                        frame_cnt <= frame_cnt + 1;
                        if(frame_cnt==5) framegen_state <= ST_PAYLOAD;
                    end
                    ST_IDLE_PAYLOAD: begin
                        if(frame_cnt[0]==1'b0) out_data <= ~out_data;
                        if(frame_cnt==7'd101) begin
                            framegen_state <= ST_IDLE;
                            frame_cnt <= 0;
                        end
                        else begin
                            frame_cnt <= frame_cnt + 1;
                        end
                    end
                    ST_PAYLOAD: begin
                        if(in_resizer_valid) begin
                            out_data <= in_resizer_data;
                            out_valid <= 1'b1;
                            if(frame_cnt==7'd101) begin
                                framegen_state <= ST_IDLE;
                                frame_cnt <= 0;
                            end
                            else begin
                                frame_cnt <= frame_cnt + 1;
                            end
                        end
                        else begin
                            out_valid <= 1'b0;
                        end
                    end
                endcase
            end
        end
    end

    assign in_resizer_ready = (framegen_state == ST_PAYLOAD) & out_ready;

    ///////////////////////////////////////////////////////////////////////////////

    logic rx_in_valid;
    (* MARK_DEBUG = "TRUE" *)logic [101:0] rx_frame;
    logic rx_ready;
    (* MARK_DEBUG = "TRUE" *)logic fifo_package_valid;

    stream_resizer
    #(
      .IN_WIDTH(1),
      .OUT_WIDTH(102)
    ) bch_stream_resizer (
      .clk(clk),
      .rst(rst),
      .in_valid(in_valid),
      .in_data(in_data),
      .in_ready(in_ready),
      .out_valid(rx_in_valid),
      .out_data(rx_frame),
      .out_ready(rx_ready)
    );

    assign fifo_package_valid = (rx_frame[101:96] == 6'b0) & rx_in_valid;

    stream_resizer
    #(
      .IN_WIDTH(96),
      .OUT_WIDTH(32)
    ) output_stream_resizer (
      .clk(clk),
      .rst(rst),
      .in_valid(fifo_package_valid),
      .in_data(rx_frame[95:0]),
      .in_ready(rx_ready),
      .out_valid(out_fifo_valid),
      .out_data(out_fifo_data),
      .out_ready(out_fifo_ready)
    );

endmodule

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

    reg data_available;
    logic [6:0] frame_cnt;
    enum { ST_IDLE, ST_IDLE_HEADER, ST_HEADER, ST_IDLE_PAYLOAD, ST_PAYLOAD } framegen_state;

    logic in_resizer_ready;

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
      .out_valid(in_resizer_valid),
      .out_data(in_resizer_data),
      .out_ready(in_resizer_ready)
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

    assign in_resizer_ready = framegen_state == ST_PAYLOAD & out_ready;

    ///////////////////////////////////////////////////////////////////////////////

    logic rx_in_valid;
    logic [101:0] rx_frame, rx_frame_buff;
    logic rx_ready;
    logic fifo_package_valid;

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

    always @(posedge clk) begin : frame_packager
        rx_frame_buff <= rx_frame;
        if(rst) begin
            fifo_package_valid <= 1'b0;
        end
        else begin
            if (rx_in_valid) begin
                if (rx_frame[101:95] == 6'b0) fifo_package_valid <= 1'b1;
                else fifo_package_valid <= 1'b0;
            end
            else fifo_package_valid <= 1'b0;
        end
    end

    stream_resizer
    #(
      .IN_WIDTH(102),
      .OUT_WIDTH(32)
    ) output_stream_resizer (
      .clk(clk),
      .rst(rst),
      .in_valid(fifo_package_valid),
      .in_data(rx_frame_buff),
      .in_ready(rx_ready),
      .out_valid(rx_in_valid),
      .out_data(out_fifo_data),
      .out_ready(out_fifo_ready)
    );

endmodule

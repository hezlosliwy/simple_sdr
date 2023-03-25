module fifo_async
#(
  parameter integer WRITE_DATA_WIDTH  = 8,
  parameter integer READ_DATA_WIDTH   = 8,
  parameter integer DATA_DEPTH        = 8,
  parameter integer PROG_EMPTY_THRESH = 0,
  parameter integer PROG_FULL_THRESH  = 0
)
(
    input  wire rst,
    input  wire in_clk,
    input  wire in_valid,
    output wire in_ready,
    input  wire[WRITE_DATA_WIDTH-1:0] in_data,
    input  wire out_clk,
    output wire out_valid,
    input  wire out_ready,
    output wire[READ_DATA_WIDTH-1:0] out_data
);

assign wr_en     = in_valid & (~full);
assign in_ready  = (~full) & (~wr_rst_busy);
assign rd_en     = out_ready & (~empty);
assign out_valid = (~rd_rst_busy) & (~empty);


xpm_fifo_async #(
  .CASCADE_HEIGHT(0),       
  .CDC_SYNC_STAGES(2),      
  .DOUT_RESET_VALUE("0"),   
  .ECC_MODE("no_ecc"),      
  .FIFO_MEMORY_TYPE("auto"),
  .FIFO_READ_LATENCY(1),    
  .FIFO_WRITE_DEPTH(DATA_DEPTH),  
  .FULL_RESET_VALUE(0),     
  .PROG_EMPTY_THRESH(10),   
  .PROG_FULL_THRESH(10),    
  .RD_DATA_COUNT_WIDTH(1),  
  .READ_DATA_WIDTH(READ_DATA_WIDTH),     
  .READ_MODE("std"),        
  .RELATED_CLOCKS(0),       
  .SIM_ASSERT_CHK(0),       
  .USE_ADV_FEATURES("0707"),
  .WAKEUP_TIME(0),          
  .WRITE_DATA_WIDTH(WRITE_DATA_WIDTH),    
  .WR_DATA_COUNT_WIDTH(1)   
)
 xpm_fifo_async_inst (
  .almost_empty(almost_empty), 
  .almost_full(almost_full),
  .data_valid(out_valid_int),  
  .dbiterr(dbiterr),            
  .dout(out_data),                  
  .empty(empty),                
  .full(full),                  
  .overflow(overflow),          
  .prog_empty(prog_empty),      
  .prog_full(prog_full),        
  .rd_data_count(rd_data_count),
  .rd_rst_busy(rd_rst_busy),    
  .sbiterr(sbiterr),            
  .underflow(underflow),        
  .wr_ack(wr_ack),              
  .wr_data_count(wr_data_count),
  .wr_rst_busy(wr_rst_busy),    
  .din(in_data),                    
  .injectdbiterr(injectdbiterr),
  .injectsbiterr(injectsbiterr),
  .rd_clk(out_clk),              
  .rd_en(rd_en),                
  .rst(rst),                    
  .sleep(sleep),                
  .wr_clk(in_clk),              
  .wr_en(wr_en)               
 );

endmodule
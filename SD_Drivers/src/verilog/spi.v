// -----------------------------------------------------------------------------
// Copyright (c) 1996-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : wenky
// File : spi.v
// email: wenkyjong1996@gmail.com
// Create : 2024-08-19
// Revise : 
// Functions : 
// 
// -----------------------------------------------------------------------------

module spi #(
   parameter CPOL = 1,//spi_clk = 1 in idle 
   parameter CPAH = 1 //data change in first edge
)
(
input                                  clk,
input                            [7:0] spi_clk_div,
input                                  rst_n,
input                            [7:0] data_write,
input                                  write_en, // a plus signal 
input                                  read_en,  // a plus signal
input                                  spi_miso,
output  reg                      [7:0] data_read,
output  reg                            spi_clk,
output  reg                            spi_cs,
output  reg                            write_busy,
output  reg                            read_busy,
output  reg                            spi_mosi
);

// state function
parameter                         IDLE = 0;
parameter                   READ_WRITE = 1;
parameter                        WRITE = 2;
parameter                         READ = 3;


reg                             [1:0]  state_next;
reg                             [1:0]  state_cur;

reg [7:0]                              cnt_clk_div;
reg [2:0]                              cnt_bit;
always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    cnt_clk_div                        <= 7'd0;
  end
  else begin
   if (cnt_clk_div == spi_clk_div-1||state_cur==IDLE) begin
      cnt_clk_div                      <= 1'b0;
   end else begin
      cnt_clk_div                      <= cnt_clk_div + 1'b1;
   end
  end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
    state_cur                          <= IDLE;
  end
  else begin
   state_cur                           <= state_next;
  end
end

always @(*) begin
   if (!rst_n) begin
      state_next                       <= 1'b0;
   end else begin
      case (state_cur)
         IDLE: begin
            if (write_en&&read_en) begin
               state_next              <= READ_WRITE; 
            end else begin
               if (write_en) begin
                  state_next           <= WRITE;
               end else begin
                  if (read_en) begin
                     state_next        <= READ;
                  end else begin
                     state_next        <= IDLE;
                  end
               end
            end
         end
         READ_WRITE:begin
            if(cnt_bit == 3'd7)begin
               state_next              <= IDLE;
            end
            else begin
               state_next              <= READ_WRITE;
            end
         end
         WRITE:begin
            if (cnt_bit == 3'd7) begin
               state_next              <= IDLE;
            end else begin
               state_next              <= WRITE;
            end
         end
         READ:begin
            if (cnt_bit == 3'd7) begin
               state_next              <= IDLE;
            end else begin
               state_next              <= READ;
            end
         end
         default: begin
            state_next                 <= IDLE;
         end
      endcase
   end
end

always @(posedge clk or negedge rst_n) begin
  if (!rst_n) begin
   spi_clk                             <= CPOL;
   spi_cs                              <= 1'b1;
   spi_mosi                            <= 1'b0;
   cnt_bit                             <= 3'b0;
   write_busy                          <= 1'b0;
   read_busy                           <= 1'b0;
  end
  else begin
   case (state_cur)
   IDLE: begin
      spi_clk                          <= CPOL;
      spi_cs                           <= 1'b1;
      spi_mosi                         <= 1'b0;
      cnt_bit                          <= 3'b0;
      write_busy                       <= 1'b0;
      read_busy                        <= 1'b0;
   end
   READ_WRITE:begin
      spi_cs                           <= 1'b0;
      write_busy                       <= 1'b1;
      read_busy                        <= 1'b1;
      if (cnt_clk_div == (spi_clk_div>>1-1)) begin
         spi_clk                       <= ~spi_clk;
         data_read[3'd7-cnt_bit]       <= spi_miso;
         if ((CPAH == 1'b1) && (spi_clk == 1'b0) ||(CPAH == 1'b0) && (spi_clk == 1'b1)) begin
            spi_mosi                   <= data_write[3'd7-cnt_bit];
         end else begin
            spi_mosi                   <= spi_mosi;
         end
      end else begin
         if (cnt_clk_div == (spi_clk_div-1)) begin
            if ((CPAH == 1'b1) && (spi_clk == 1'b0) ||(CPAH == 1'b0) && (spi_clk == 1'b1)) begin
               spi_mosi                <= data_write[3'd7-cnt_bit];
            end else begin
               spi_mosi                <= spi_mosi;
            end
            spi_clk                    <= ~spi_clk;
            cnt_bit                    <= cnt_bit + 1'b1;
         end else begin
            spi_clk                    <= spi_clk;
         end
      end
   end
   WRITE:begin
      spi_cs                           <= 1'b0;
      write_busy                       <= 1'b1;
      if (cnt_clk_div == (spi_clk_div>>1)-1) begin
         spi_clk                       <= ~spi_clk;
         if ((CPAH == 1'b1) && (spi_clk == 1'b0) ||(CPAH == 1'b0) && (spi_clk == 1'b1)) begin
            spi_mosi                   <= data_write[3'd7-cnt_bit];
         end else begin
            spi_mosi                   <= spi_mosi;
         end
      end else begin
         if (cnt_clk_div == (spi_clk_div-1)) begin
            spi_clk                    <= ~spi_clk;
            cnt_bit                    <= cnt_bit + 1'b1;
            if ((CPAH == 1'b1) && (spi_clk == 1'b0) ||(CPAH == 1'b0) && (spi_clk == 1'b1)) begin
               spi_mosi                <= data_write[3'd7-cnt_bit];
            end else begin
               spi_mosi                <= spi_mosi;
            end
         end else begin
            spi_clk                    <= spi_clk;
         end
      end
   end
   READ:begin
      spi_cs                           <= 1'b0;
      read_busy                        <= 1'b1;
      if (cnt_clk_div == (spi_clk_div>>1)-1) begin
         spi_clk                       <= spi_clk;
         data_read[3'd7-cnt_bit]       <= spi_miso;
      end else begin
         if (cnt_clk_div == spi_clk_div-1) begin
            cnt_bit                    <= cnt_bit+1'b1;
         end else begin
            cnt_bit                    <= cnt_bit;
         end
      end
   end
      default: begin
         spi_clk                       <= CPOL;
         cnt_bit                       <= 1'b0;
         spi_cs                        <= 1'b1;
         data_read                     <= 1'b0;
         spi_mosi                      <= 1'b0;
      end   
   endcase
  end
end


endmodule
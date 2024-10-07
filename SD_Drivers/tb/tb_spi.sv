// -----------------------------------------------------------------------------
// Copyright (c) 1996-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : wenky
// File : tb_spi
// email: wenkyjong1996@gmail.com
// Create : 2024-09-17
// Revise : 
// Functions : 
// 
// -----------------------------------------------------------------------------
module tb_spi;

  // Parameters
  localparam  CPOL = 1;
  localparam  CPAH = 1;

  //Ports
  reg  clk;
  reg [7:0] spi_clk_div;
  reg  rst_n;
  reg [7:0] data_write;
  reg  write_en;
  reg  read_en;
  reg  spi_miso;
  wire [7:0] data_read;
  wire  spi_clk;
  wire  spi_cs;
  wire  write_busy;
  wire  read_busy;
  wire  spi_mosi;

  spi # (
    .CPOL(CPOL),
    .CPAH(CPAH)
  )
  spi_inst (
    .clk                               (clk                                    ),
    .spi_clk_div                       (spi_clk_div                            ),
    .rst_n                             (rst_n                                  ),
    .data_write                        (data_write                             ),
    .write_en                          (write_en                               ),
    .read_en                           (read_en                                ),
    .spi_miso                          (spi_miso                               ),
    .data_read                         (data_read                              ),
    .spi_clk                           (spi_clk                                ),
    .spi_cs                            (spi_cs                                 ),
    .write_busy                        (write_busy                             ),
    .read_busy                         (read_busy                              ),
    .spi_mosi                          (spi_mosi                               )
  );

always #5  clk = ! clk ;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    write_en = 1'b0;
    read_en = 1'b0;
    spi_clk_div = 4'd6;
    data_write = 8'hf4;
    #100
    rst_n = 1'b1;
    #100
    write_en = 1'b1;
    #10
    write_en = 1'b0;
    wait(write_busy == 1'b0);
    #100
    read_en  = 1'b1;
    #10
    read_en  = 1'b0;
    #1000
    $finish();
end

initial begin
$fsdbDumpfile("tb_spi.fsdb");
$fsdbDumpvars();
$fsdbDumpMDA();
end

endmodule
// -----------------------------------------------------------------------------
// Copyright (c) 1996-2024 All rights reserved
// -----------------------------------------------------------------------------
// Author : wenky
// File : sd_top
// email: wenkyjong1996@gmail.com
// Create : 2024-08-19
// Revise : 
// Functions : 
// 
// -----------------------------------------------------------------------------

module sd_top (
    input   sclk,
    input   rst_n,
    output  sd_clk,
    output  spi_mosi
);

spi # (
    .CPOL(1),
    .CPAH(1)
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
endmodule
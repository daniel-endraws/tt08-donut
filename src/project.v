/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`define SQ(X) (((X) * (X)) >> 8)
`define SQHD(X) (((X) * (X)) >> 7)
`define TRIPLE(X) ((X) + ((X) << 1))

module tt_um_dendraws_donut (
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs assigned to 0.
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused signals warning
  wire _unused_ok = &{ena, ui_in, uio_in};

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  wire [20:0] i;

  // Major Axis
  wire [6:0] d1 = (`SQ(pix_x - 320) >> 1) + `SQ(pix_y - 240);
  assign i[0] = d1 < 7'd50 && d1 > 7'd45;

  wire [6:0] d2 = `SQ(pix_x - 320) + `TRIPLE(`SQ(pix_y - 229));
  assign i[1] = d2 < 100 && d2 > 90 && pix_y > 230;

  wire [6:0] a1 = `SQ(pix_x - 320);
  wire [5:0] d3 = ((a1 >> 1) - (a1 >> 3)) + `SQ(pix_y - 207);
  assign i[2] = d3 < 30 && d3 > 26 && pix_y > 150;
  wire [7:0] d4 = `SQ(pix_x - 320) + `TRIPLE(`SQ(pix_y - 205));
  assign i[3] = d4 < 43 && d4 > 36;

  wire [8:0] d5 = `SQHD(pix_x - 320) + `TRIPLE(`SQHD(pix_y - 205));
  assign i[4] = d5 < 35 && d5 > 27;

  wire [7:0] d6 = (`SQ(pix_x - 320) >> 1) + `SQ(pix_y - 250);
  assign i[5] = d6 < 14 && d6 > 11 && pix_y < 210;

  
  wire [6:0] d7 = `SQ(pix_x - 320) + `SQ(pix_y - 291);
  assign i[6] = d7 < 25 && d7 > 22 && pix_y < 233;

  // Minor Axis Right

  wire [6:0] d8 = `SQ(pix_x - 305) + (`SQ(pix_y - 312) >> 1);
  assign i[7] = d8 < 15 && d8 > 11 && pix_x > 338;

  wire [6:0] a2 = `SQ(pix_y - 305);
  wire [5:0] d9 = `SQ(pix_x - 362) + ((a2 >> 1) + (a2 >> 3));
  assign i[8] = d9 < 15 && d9 > 12 && pix_x > 375 && pix_y < 305;

  wire [6:0] a3 = `SQ(pix_x - 276);
  wire [5:0] d10 = ((a3 >> 1) - (a3 >> 3)) + `SQ(pix_y - 293);
  assign i[9] = d10 < 33 && d10 > 29 && pix_x > 320 && pix_y >= 225;

  wire [5:0] d11 = `SQ(pix_x - 397) + `SQ(pix_y - 266);
  assign i[10] = d11 < 16 && d11 > 12 && pix_x > 380 && pix_y < 305;

  wire [7:0] a4 = `SQ(pix_x - 414);
  wire [7:0] d12 = (a4 + (a4 >> 2)) + `SQ(pix_y - 230);
  assign i[11] = d12 < 16 && d12 > 12 && pix_y < 225 && pix_x < 455;

  wire [7:0] d13 = (a4 - (a4 >> 2)) + `SQ(pix_y - 210);
  assign i[12] = d13 < 16 && d13 > 13 && pix_y < 218;

  wire [7:0] d14 = `SQ(pix_x - 414) + `SQ(pix_y - 202);
  assign i[13] = d14 < 31 && d14 > 27 && pix_y < 215;

  // Minor Axis Left
  
  wire [9:0] pix_x_mirr = 640 - pix_x;

  wire [6:0] d15 = `SQ(pix_x_mirr - 305) + (`SQ(pix_y - 312) >> 1);
  assign i[14] = d15 < 15 && d15 > 11 && pix_x_mirr > 338;

  wire [5:0] d16 = `SQ(pix_x_mirr - 362) + ((a2 >> 1) + (a2 >> 3));
  assign i[15] = d16 < 15 && d16 > 12 && pix_x_mirr > 375 && pix_y < 305;

  wire [6:0] a6 = `SQ(pix_x_mirr - 276);
  wire [5:0] d17 = ((a6 >> 1) - (a6 >> 3)) + `SQ(pix_y - 293);
  assign i[16] = d17 < 33 && d17 > 29 && pix_x_mirr > 320 && pix_y > 225;

  wire [5:0] d18 = `SQ(pix_x_mirr - 397) + `SQ(pix_y - 266);
  assign i[17] = d18 < 16 && d18 > 12 && pix_x_mirr > 380 && pix_y < 305;

  wire [7:0] a7 = `SQ(pix_x_mirr - 414);
  wire [7:0] d19 = (a7 + (a7 >> 2)) + `SQ(pix_y - 230);
  assign i[18] = d19 < 16 && d19 > 12 && pix_y < 225 && pix_x_mirr < 455;

  wire [7:0] d20 = (a7 - (a7 >> 2)) + `SQ(pix_y - 210);
  assign i[19] = d20 < 16 && d20 > 13 && pix_y < 218;

  wire [7:0] d21 = `SQ(pix_x_mirr - 414) + `SQ(pix_y - 202);
  assign i[20] = d21 < 31 && d21 > 27 && pix_y < 215;

  wire in_bounds = d1 < 50;
  wire light = in_bounds && |i;
  wire [1:0] value = {2{light}};

  assign R = video_active ? value : 2'b00;
  assign G = video_active ? value : 2'b00;
  assign B = video_active ? value : 2'b00;
  
  
endmodule


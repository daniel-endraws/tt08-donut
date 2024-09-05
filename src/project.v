/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
`define SQ(X) \
  ((X) * (X))

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

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  wire [22:0] i;

  // Major Axis
  wire [13:0] d1 = (`SQ(pix_x - 320) >> 1) + `SQ(pix_y - 240);
  assign i[0] = d1 < 10000 && d1 > 9500;

  wire [15:0] d2 = `SQ(pix_x - 320) + (3 * `SQ(pix_y - 228));
  assign i[1] = d2 < 20000 && d2 > 19100 && pix_y > 230;

  wire [16:0] a1 = `SQ(pix_x - 320);
  wire [16:0] d3 = ((a1 >> 1) - (a1 >> 3)) + `SQ(pix_y - 210);
  assign i[2] = d3 > 5230 && d3 < 5500 && pix_y > 170;

  wire [16:0] d4 = `SQ(pix_x - 320) + (3 * `SQ(pix_y - 205));
  assign i[3] = d4 < 8600 && d4 > 8100;

  wire [16:0] d5 = `SQ(pix_x - 320) + (3 * `SQ(pix_y - 206));
  assign i[4] = d5 < 3870 && d5 > 3570;

  wire [14:0] d6 = (`SQ(pix_x - 320) >> 2) + `SQ(pix_y - 225);
  assign i[5] = d6 < 686 && d6 > 600 && pix_y < 225;

  wire [15:0] d7 = `SQ(pix_x - 320) + `SQ(pix_y - 291);
  assign i[6] = d7 < 5093 && d7 > 4793 && pix_y < 233;

  // Minor Axis Right

  wire [14:0] d8 = `SQ(pix_x - 309) + (`SQ(pix_y - 311) >> 2);
  assign i[7] = d8 < 1850 && d8 > 1700 && pix_x > 332 && pix_y < 338;

  wire [14:0] a2 = `SQ(pix_y - 305);
  wire [14:0] d9 = `SQ(pix_x - 362) + ((a2 >> 1) + (a2 >> 3));
  assign i[8] = d9 < 3100 && d9 > 2900 && pix_x > 354 && pix_y < 290;

  wire [14:0] a3 = `SQ(pix_x - 276);
  wire [12:0] d10 = ((a3 >> 1) - (a3 >> 3)) + `SQ(pix_y - 293);
  assign i[9] = d10 < 7400 && d10 > 7200 && pix_x > 320 && pix_y > 285 && pix_y < 316;

  wire [14:0] d11 = `SQ(pix_x - 401) + `SQ(pix_y - 266);
  assign i[10] = d11 < 2654 && d11 > 2454 && pix_x > 362 && pix_y < 275;

  wire [15:0] a4 = `SQ(pix_x - 414);
  wire [15:0] d12 = (a4 - (a4 >> 2)) + `SQ(pix_y - 230);
  assign i[11] = d12 < 1693 && d12 > 1540 && pix_x < 450 && pix_y < 230;

  wire [15:0] a5 = `SQ(pix_x - 422);
  wire [15:0] d13 = (a4 - (a4 >> 2)) + `SQ(pix_y - 214);
  assign i[12] = d13 < 2813 && d13 > 2630 && pix_x < 408 && pix_y < 230;

  wire [15:0] d14 = `SQ(pix_x - 413) + `SQ(pix_y - 202);
  assign i[13] = d14 < 5300 && d14 > 5000 && pix_x < 367 && pix_y < 224;

  wire [14:0] d15 = `SQ(pix_x - 348) + (`SQ(pix_y - 193) >> 3);
  assign i[14] = d15 < 450 && d15 > 370 && pix_x < 337 && pix_y < 221;

  // Minor Axis Left
  wire [9:0] pix_x_mirr = 640 - pix_x;

  wire [14:0] d16 = `SQ(pix_x_mirr - 309) + (`SQ(pix_y - 311) >> 2);
  assign i[15] = d16 < 1850 && d16 > 1700 && pix_x_mirr > 332 && pix_y < 338;

  wire [14:0] a6 = `SQ(pix_y - 305);
  wire [14:0] d17 = `SQ(pix_x_mirr - 362) + ((a6 >> 1) + (a6 >> 3));
  assign i[16] = d17 < 3100 && d17 > 2900 && pix_x_mirr > 354 && pix_y < 290;

  wire [14:0] a7 = `SQ(pix_x_mirr - 276);
  wire [12:0] d18 = ((a7 >> 1) - (a7 >> 3)) + `SQ(pix_y - 293);
  assign i[17] = d18 < 7400 && d18 > 7200 && pix_x_mirr > 320 && pix_y > 285 && pix_y < 316;

  wire [14:0] d19 = `SQ(pix_x_mirr - 401) + `SQ(pix_y - 266);
  assign i[18] = d19 < 2654 && d19 > 2454 && pix_x_mirr > 362 && pix_y < 275;

  wire [15:0] a8 = `SQ(pix_x_mirr - 414);
  wire [15:0] d20 = (a8 - (a8 >> 2)) + `SQ(pix_y - 230);
  assign i[19] = d20 < 1693 && d20 > 1540 && pix_x_mirr < 450 && pix_y < 230;

  wire [15:0] a9 = `SQ(pix_x_mirr - 422);
  wire [15:0] d21 = (a9 - (a9 >> 2)) + `SQ(pix_y - 214);
  assign i[20] = d21 < 2813 && d21 > 2630 && pix_x_mirr < 408 && pix_y < 230;

  wire [15:0] d22 = `SQ(pix_x_mirr - 413) + `SQ(pix_y - 202);
  assign i[21] = d22 < 5300 && d22 > 5000 && pix_x_mirr < 367 && pix_y < 224;

  wire [14:0] d23 = `SQ(pix_x_mirr - 348) + (`SQ(pix_y - 193) >> 3);
  assign i[22] = d23 < 450 && d23 > 370 && pix_x_mirr < 337 && pix_y < 221;

  wire in_bounds = pix_x_mirr > 170 && pix_y > 135 && pix_x_mirr < 470 && pix_y < 345;
  wire light = in_bounds && |i;
  wire [1:0] value = {2{light}};

  assign R = video_active ? value : 2'b01;
  assign G = video_active ? value : 2'b00;
  assign B = video_active ? value : 2'b00;
  
  
endmodule


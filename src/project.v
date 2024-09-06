/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
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

  // ------------------------------ Major Axis ------------------------------
  
  // ------------------------------
  wire [6:0] d1_x, d1_y;
  square #(.N(10), .K(7), .POST_SHIFT(8)) square_d1_x (.in(pix_x - 10'd320), .out(d1_x));
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d1_y (.in(pix_y - 10'd240), .out(d1_y));
  wire [6:0] d1 = (d1_x >> 1) + d1_y;
  assign i[0] = d1 < 7'd52 && d1 > 7'd45;

  // ------------------------------
  wire [6:0] d2_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d2_y (.in(pix_y - 10'd229), .out(d2_y));
  wire [6:0] d2 = d1_x + `TRIPLE(d2_y);
  assign i[1] = d2 < 7'd100 && d2 > 90 && pix_y > 230;

  // ------------------------------
  wire [6:0] d3_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d3_y (.in(pix_y - 10'd205), .out(d3_y));
  wire [5:0] d3 = ((d1_x >> 1) - (d1_x >> 3)) + d3_y;
  assign i[2] = d3 < 30 && d3 > 26 && pix_y > 150;

  // ------------------------------
  wire [7:0] d4 = d1_x + `TRIPLE(d3_y);
  assign i[3] = d4 < 43 && d4 > 37;

  // ------------------------------
  wire [7:0] d5 = d1_x + `TRIPLE(d3_y);
  assign i[4] = d5 < 18 && d5 > 13;

  // ------------------------------
  wire [5:0] d6_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d6_y (.in(pix_y - 10'd250), .out(d6_y));
  wire [5:0] d6 = (d1_x >> 1) + d6_y;
  assign i[5] = d6 < 14 && d6 > 11 && pix_y < 210;

  // ------------------------------
  wire [6:0] d7_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d7_y (.in(pix_y - 10'd291), .out(d7_y));
  wire [6:0] d7 = d1_x + d7_y;
  assign i[6] = d7 < 25 && d7 > 22 && pix_y < 233;


  // ------------------------------ Minor Axis Right ------------------------------

  // ------------------------------
  wire [6:0] d8_x, d8_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d8_x (.in(pix_x - 10'd305), .out(d8_x));
  square #(.N(10), .K(5), .POST_SHIFT(8)) square_d8_y (.in(pix_y - 10'd305), .out(d8_y));
  wire [6:0] d8 = d8_x + (d8_y >> 1);
  assign i[7] = d8 < 15 && d8 > 11 && pix_x > 344;

  // ------------------------------
  wire [6:0] d9_x, d9_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d9_x (.in(pix_x - 10'd362), .out(d9_x));
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d9_y (.in(pix_y - 10'd305), .out(d9_y));
  wire [5:0] d9 = d9_x + ((d9_y >> 1) + (d9_y >> 3));
  assign i[8] = d9 < 15 && d9 > 12 && pix_x > 375 && pix_y < 305;

  // ------------------------------
  wire [7:0] d10_x;
  square #(.N(10), .K(7), .POST_SHIFT(8)) square_d10_x (.in(pix_x - 10'd276), .out(d10_x));
  wire [6:0] d10 = ((d10_x >> 1) - (d10_x >> 3)) + d7_y;
  assign i[9] = d10 < 33 && d10 > 29 && pix_x > 320 && pix_y >= 225;

  // ------------------------------
  wire [6:0] d11_x, d11_y;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d11_x (.in(pix_x - 10'd397), .out(d11_x));
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d11_y (.in(pix_y - 10'd266), .out(d11_y));
  wire [5:0] d11 = d11_x + d11_y;
  assign i[10] = d11 < 16 && d11 > 12 && pix_x > 380 && pix_y < 305;

  // ------------------------------
  wire [7:0] d12_x;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d12_x (.in(pix_x - 10'd414), .out(d12_x));
  wire [8:0] d12 = (d12_x + (d12_x >> 2)) + d2_y;
  assign i[11] = d12 < 16 && d12 > 12 && pix_y < 225 && pix_x < 455;

  // ------------------------------
  wire [7:0] d13 = (d12_x - (d12_x >> 2)) + d3_y;
  assign i[12] = d13 < 18 && d13 > 15 && pix_y < 218;

  // ------------------------------
  wire [7:0] d14 = d12_x + d3_y;
  assign i[13] = d14 < 35 && d14 > 31 && pix_y < 215;


  // ------------------------------ Minor Axis Left ------------------------------
  wire [9:0] pix_x_mirr = 640 - pix_x;

  // ------------------------------ 
  wire [6:0] d15_x;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d15_x (.in(pix_x_mirr - 10'd305), .out(d15_x));
  wire [6:0] d15 = d15_x + (d8_y >> 1);
  assign i[14] = d15 < 15 && d15 > 11 && pix_x_mirr > 344;

  // ------------------------------
  wire [6:0] d16_x;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d16_x (.in(pix_x_mirr - 10'd362), .out(d16_x));
  wire [5:0] d16 = d16_x + ((d9_y >> 1) + (d9_y >> 3));
  assign i[15] = d16 < 15 && d16 > 12 && pix_x_mirr > 375 && pix_y < 305;

  // ------------------------------
  wire [7:0] d17_x;
  square #(.N(10), .K(7), .POST_SHIFT(8)) square_d17_x (.in(pix_x_mirr - 10'd276), .out(d17_x));
  wire [6:0] d17 = ((d17_x >> 1) - (d17_x >> 3)) + d7_y;
  assign i[16] = d17 < 33 && d17 > 29 && pix_x_mirr > 320 && pix_y >= 225;

  // ------------------------------
  wire [6:0] d18_x;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d18_x (.in(pix_x_mirr - 10'd397), .out(d18_x));
  wire [5:0] d18 = d18_x + d11_y;
  assign i[17] = d18 < 16 && d18 > 12 && pix_x_mirr > 380 && pix_y < 305;

  // ------------------------------
  wire [7:0] d19_x;
  square #(.N(10), .K(6), .POST_SHIFT(8)) square_d19_x (.in(pix_x_mirr - 10'd414), .out(d19_x));
  wire [8:0] d19 = (d19_x + (d19_x >> 2)) + d2_y;
  assign i[18] = d19 < 16 && d19 > 12 && pix_y < 225 && pix_x_mirr < 455;

  // ------------------------------
  wire [7:0] d20 = (d19_x - (d19_x >> 2)) + d3_y;
  assign i[19] = d20 < 18 && d20 > 15 && pix_y < 218;

  // ------------------------------
  wire [7:0] d21 = d19_x + d3_y;
  assign i[20] = d21 < 35 && d21 > 31 && pix_y < 215;

  // ------------------------------ Display ------------------------------

  wire in_bounds_rect = pix_x > 150 && pix_y > 120 && pix_x < 490 && pix_y < 360;
  wire in_bounds_circ = d1 < 52;
  wire light = in_bounds_rect && in_bounds_circ && |i;
  wire [1:0] value = {2{light}};

  assign R = video_active ? value : 2'b00;
  assign G = video_active ? value : 2'b00;
  assign B = video_active ? value : 2'b00;
  
  
endmodule
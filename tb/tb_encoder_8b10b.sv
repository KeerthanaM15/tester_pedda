////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Wednesday 04 Jan 2023 10:15:00 IST              *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: Encoder 8bit to 10bit module                   *////
////*  Submodule: encoder, disparity                               *////
////////////////////////////////////////////////////////////////////////

`include "./tb_disparity.sv"
`include "./tb_encoder_3b4b.sv"
`include "./tb_encoder_5b6b.sv"
`include "./tb_encoder.sv"
module tb_encoder_8b10b (clk,
                      rst_n,
                      k_in,
                      data_in,
                      k_err,
                      data_out);

  input        clk;     //clock for 8b10b
  input        rst_n;   //active low reset
  input        k_in;    //K/D symbol
  input  [7:0] data_in; //data input
  output [9:0] data_out;//data outpur
  output       k_err;   //K symbol error
  
  wire disp_in;
  
  encoder encoder ( 
            .clk       (clk),
            .rst_n     (rst_n),
            .disp_in   (disp_in),
            .data_in   (data_in),
            .k_in      (k_in),
            .k_err     (k_err),
            .data_out  (data_out)
            );
  
  disparity disparity ( 
            .clk       (clk),
            .rst_n     (rst_n),
            .data_in   (data_out),
            .disp_out  (disp_in)
            );
  
endmodule


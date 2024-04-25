////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Friday 11 Aug 2023 08:10:00 IST                 *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: Encoder top module                             *////
////*  Submodule: encoder_5b6b, encoder_3b4b                       *////
////////////////////////////////////////////////////////////////////////

module encoder (clk,
                rst_n,
                disp_in,
                data_in,
                k_in,
                k_err,
                data_out);

  input            clk;
  input            rst_n;
  input            disp_in; //disparity input
  input            k_in;    //K/D symbol
  input      [7:0] data_in; //data input
  output reg       k_err;   //K symbol Error
  output reg [9:0] data_out;//data output
  
  wire       d_select;
  wire       k_select;
  wire       k_err_5b6b;
  wire       k_err_3b4b;
  wire [9:0] data_out_temp;
  
  always@(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
      k_err    <= 1'b0;
      data_out <= 10'b0;
    end
    else begin
      k_err    <= k_err_5b6b | k_err_3b4b;
      data_out <= data_out_temp;
    end
  end
  
  encoder_5b6b encoder_5b6b (.k_in     (k_in),
                             .disp_in  (disp_in),
                             .data_in  (data_in[4:0]),
                             .data_out (data_out_temp[9:4]),
                             .d_select (d_select),
                             .k_select (k_select),
                             .k_err    (k_err_5b6b));
  
  encoder_3b4b encoder_3b4b (.k_in     (k_in),
                             .disp_in  (~disp_in),
                             .data_in  (data_in[7:5]),
                             .d_select (d_select),
                             .k_select (k_select),
                             .k_err    (k_err_3b4b),
                             .data_out (data_out_temp[3:0]));
  
endmodule


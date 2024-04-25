////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Friday 11 Aug 2023 08:10:00 IST                 *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: Encoder 3bit to4 bit module                    *////
////////////////////////////////////////////////////////////////////////

module encoder_3b4b (k_in,
                     disp_in,
                     data_in,
                     k_err,
                     d_select,
                     k_select,
                     data_out);

  input              k_in;     //K/D symbol
  input              disp_in;  //disparity check input
  input        [2:0] data_in;  //input data
  input              d_select;
  input              k_select;
  output reg [3:0]   data_out; //output data
  output reg         k_err;    //K symbolm error
  
  always@(*)
    begin
      if(k_in)
        begin
          k_err = 1'b0;
          case(data_in)
            3'b000: data_out = (disp_in) ? 4'b1011 : 4'b0100;
            3'b001: data_out = (disp_in) ? 4'b0110 : 4'b1001;
            3'b010: data_out = (disp_in) ? 4'b1010 : 4'b0101;
            3'b011: data_out = (disp_in) ? 4'b1100 : 4'b0011;
            3'b100: data_out = (disp_in) ? 4'b1101 : 4'b0010;
            3'b101: data_out = (disp_in) ? 4'b0101 : 4'b1010;
            3'b110: data_out = (disp_in) ? 4'b1001 : 4'b0110;
            3'b111: data_out = (disp_in) ? 4'b0111 : 4'b1000;
            default:
              begin
                data_out = 4'b1011;
                k_err = 1'b1;
              end
          endcase
        end
      else
        begin
          k_err = 1'b0;
          case(data_in)
            3'b000: data_out = (disp_in) ? (d_select ? 4'b1011 : 4'b0100) : (d_select ? 4'b0100 : 4'b1011);
            3'b001: data_out = 4'b1001;
            3'b010: data_out = 4'b0101;
            3'b011: data_out = (disp_in) ? (d_select ? 4'b1100 : 4'b0011) : (d_select ? 4'b0011 : 4'b1100);
            3'b100: data_out = (disp_in) ? (d_select ? 4'b1101 : 4'b0010) : (d_select ? 4'b0010 : 4'b1101);
            3'b101: data_out = 4'b1010;
            3'b110: data_out = 4'b0110;
            3'b111: data_out = (disp_in) ? (k_select ? 4'b1000 : (d_select ? 4'b1110 : 4'b0001)) : (k_select ? 4'b0111 : (d_select ? 4'b0001 : 4'b1110));
            default:
              begin
                data_out = 4'b1011;
                k_err = 1'b1;
              end
          endcase
        end
    end
  
endmodule


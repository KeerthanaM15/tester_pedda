////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Friday 11 Aug 2023 08:10:00 IST                 *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: Encoder 5bit to 6bit module                    *////
////////////////////////////////////////////////////////////////////////

module encoder_5b6b (k_in,
                     disp_in,
                     k_err,
                     data_in,
                     d_select,
                     k_select,
                     data_out);

  input              k_in;    //K/D symbol
  input              disp_in; //disparity input
  input        [4:0] data_in; //input data
  output reg [5:0]   data_out;//output dataA
  output reg         k_err;   //K symbol error
  output reg         d_select; //RD- value for disp_in=0 at 3b4b
  output reg         k_select; //RD- value for disp_in=0 at 3b4b
  
  //0,1,2,4,8,15,16,23,24,27,29,30,31
  always@(*)
    begin
      case(data_in)
        5'b00000: begin d_select = 1'b1; k_select = 1'b0; end 
        5'b00001: begin d_select = 1'b1; k_select = 1'b0; end
        5'b00010: begin d_select = 1'b1; k_select = 1'b0; end
        5'b00011: begin d_select = 1'b0; k_select = 1'b0; end
        5'b00100: begin d_select = 1'b1; k_select = 1'b0; end
        5'b00101: begin d_select = 1'b0; k_select = 1'b0; end
        5'b00110: begin d_select = 1'b0; k_select = 1'b0; end
        5'b00111: begin d_select = 1'b0; k_select = 1'b0; end
        5'b01000: begin d_select = 1'b1; k_select = 1'b0; end
        5'b01001: begin d_select = 1'b0; k_select = 1'b0; end
        5'b01010: begin d_select = 1'b0; k_select = 1'b0; end
        5'b01011: begin d_select = 1'b0; k_select = (disp_in) ? 1'b0 : 1'b1; end //11 rd-
        5'b01100: begin d_select = 1'b0; k_select = 1'b0; end 
        5'b01101: begin d_select = 1'b0; k_select = (disp_in) ? 1'b0 : 1'b1; end //13 rd-
        5'b01110: begin d_select = 1'b0; k_select = (disp_in) ? 1'b0 : 1'b1; end //14 rd-
        5'b01111: begin d_select = 1'b1; k_select = 1'b0; end
        5'b10000: begin d_select = 1'b1; k_select = 1'b0; end
        5'b10001: begin d_select = 1'b0; k_select = (disp_in) ? 1'b1 : 1'b0; end //17 rd+
        5'b10010: begin d_select = 1'b0; k_select = (disp_in) ? 1'b1 : 1'b0; end //18 rd+
        5'b10011: begin d_select = 1'b0; k_select = 1'b0; end
        5'b10100: begin d_select = 1'b0; k_select = (disp_in) ? 1'b1 : 1'b0; end //20 rd+
        5'b10101: begin d_select = 1'b0; k_select = 1'b0; end
        5'b10110: begin d_select = 1'b0; k_select = 1'b0; end
        5'b10111: begin d_select = 1'b1; k_select = 1'b0; end
        5'b11000: begin d_select = 1'b1; k_select = 1'b0; end
        5'b11001: begin d_select = 1'b0; k_select = 1'b0; end
        5'b11010: begin d_select = 1'b0; k_select = 1'b0; end
        5'b11011: begin d_select = 1'b1; k_select = 1'b0; end
        5'b11100: begin d_select = 1'b0; k_select = 1'b0; end
        5'b11101: begin d_select = 1'b1; k_select = 1'b0; end
        5'b11110: begin d_select = 1'b1; k_select = 1'b0; end
        5'b11111: begin d_select = 1'b1; k_select = 1'b0; end
      endcase
        end
  
  always@(*)
    begin
      if(k_in)
        begin
          k_err = 1'b0;
          case(data_in)
            5'b10111: data_out = (disp_in) ? 6'b111010 : 6'b000101;
            5'b11011: data_out = (disp_in) ? 6'b110110 : 6'b001001;
            5'b11100: data_out = (disp_in) ? 6'b001111 : 6'b110000;
            5'b11101: data_out = (disp_in) ? 6'b101110 : 6'b010001;
            5'b11110: data_out = (disp_in) ? 6'b011110 : 6'b100001;
            default: 
              begin
                data_out = 6'b111100;
                k_err = 1'b1;
              end
          endcase
        end
      else
        begin
          k_err = 1'b0;
          case(data_in)
            5'b00000: data_out = (disp_in) ? 6'b100111 : 6'b011000;
            5'b00001: data_out = (disp_in) ? 6'b011101 : 6'b100010;
            5'b00010: data_out = (disp_in) ? 6'b101101 : 6'b010010;
            5'b00011: data_out = 6'b110001;
            5'b00100: data_out = (disp_in) ? 6'b110101 : 6'b001010;
            5'b00101: data_out = 6'b101001;
            5'b00110: data_out = 6'b011001;
            5'b00111: data_out = (disp_in) ? 6'b111000 : 6'b000111;
            5'b01000: data_out = (disp_in) ? 6'b111001 : 6'b000110;
            5'b01001: data_out = 6'b100101;
            5'b01010: data_out = 6'b010101;
            5'b01011: data_out = 6'b110100;
            5'b01100: data_out = 6'b001101;
            5'b01101: data_out = 6'b101100;
            5'b01110: data_out = 6'b011100;
            5'b01111: data_out = (disp_in) ? 6'b010111 : 6'b101000;
            5'b10000: data_out = (disp_in) ? 6'b011011 : 6'b100100;
            5'b10001: data_out = 6'b100011;
            5'b10010: data_out = 6'b010011;
            5'b10011: data_out = 6'b110010;
            5'b10100: data_out = 6'b001011;
            5'b10101: data_out = 6'b101010;
            5'b10110: data_out = 6'b011010;
            5'b10111: data_out = (disp_in) ? 6'b111010 : 6'b000101;
            5'b11000: data_out = (disp_in) ? 6'b110011 : 6'b001100;
            5'b11001: data_out = 6'b100110;
            5'b11010: data_out = 6'b010110;
            5'b11011: data_out = (disp_in) ? 6'b110110 : 6'b001001;
            5'b11100: data_out = 6'b001110;
            5'b11101: data_out = (disp_in) ? 6'b101110 : 6'b010001;
            5'b11110: data_out = (disp_in) ? 6'b011110 : 6'b100001;
            5'b11111: data_out = (disp_in) ? 6'b101011 : 6'b010100;
          endcase
        end
    end
  
endmodule


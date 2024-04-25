////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Friday 11 Aug 2023 08:10:00 IST                 *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: Decoder 10bit to 8bit module                   *////
////////////////////////////////////////////////////////////////////////

module decoding_10b8b (clk,rst_n,data_in,rdisp_in,code_err,disp_err,k_out,data_out);

  input            clk;
  input            rst_n;
  input [9:0]      data_in;  //input data
  input            rdisp_in; //disparity input
  output reg [7:0] data_out; //output data
  output reg       code_err; //invalid data received
  output reg       k_out;    //K/D symbol
  output reg       disp_err; //disparity Error

  reg [4:0] data_out_5b;
  reg       rd_data;
  reg       rd_m_data;
  reg       d_5b;
  reg       d_k_5b;
  reg [2:0] data_out_3b;
  reg       rd_m_k_5b;
  reg       d_k_3b;
  reg       rd_m_k;
  reg       code_err_temp;
  wire      data_rd_p;
  wire      k_rd_p;
  wire      disp_err_d;
  wire      disp_err_k;

always@(*)
  begin
    code_err_temp = 1'b0;
    case(data_in[9:4])
      //Data RD- start //latches - rd_m_k_5b
      6'b100111 : begin data_out_5b = 5'b00000; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b011101 : begin data_out_5b = 5'b00001; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b101101 : begin data_out_5b = 5'b00010; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b110101 : begin data_out_5b = 5'b00100; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b111000 : begin data_out_5b = 5'b00111; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b111001 : begin data_out_5b = 5'b01000; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b010111 : begin data_out_5b = 5'b01111; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b011011 : begin data_out_5b = 5'b10000; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b110011 : begin data_out_5b = 5'b11000; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b101011 : begin data_out_5b = 5'b11111; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end 
      6'b111010 : begin data_out_5b = 5'b10111; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end  // K RD- and D RD- check 
      6'b110110 : begin data_out_5b = 5'b11011; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end  // K RD- and D RD- check
      6'b101110 : begin data_out_5b = 5'b11101; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end  // K RD- and D RD- check
      6'b011110 : begin data_out_5b = 5'b11110; rd_data = 1'b0; rd_m_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end  // K RD- and D RD- check
      //Data RD- end
      //Data RD- and Data RD+ start //latches - rd_m_data,rd_m_k_5b
      6'b110001 : begin data_out_5b = 5'b00011; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b101001 : begin data_out_5b = 5'b00101; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b011001 : begin data_out_5b = 5'b00110; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b100101 : begin data_out_5b = 5'b01001; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b010101 : begin data_out_5b = 5'b01010; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b110100 : begin data_out_5b = 5'b01011; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b001101 : begin data_out_5b = 5'b01100; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b101100 : begin data_out_5b = 5'b01101; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b011100 : begin data_out_5b = 5'b01110; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b100011 : begin data_out_5b = 5'b10001; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b010011 : begin data_out_5b = 5'b10010; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b110010 : begin data_out_5b = 5'b10011; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b001011 : begin data_out_5b = 5'b10100; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b101010 : begin data_out_5b = 5'b10101; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b011010 : begin data_out_5b = 5'b10110; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b100110 : begin data_out_5b = 5'b11001; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b010110 : begin data_out_5b = 5'b11010; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      6'b001110 : begin data_out_5b = 5'b11100; rd_data = 1'b1; d_5b = 1'b1; d_k_5b = 1'b1; rd_m_data = 1'b1; rd_m_k_5b = 1'b1; end //Common D RD+ and D RD-
      //Data RD- and Data RD+ end
      //Data RD+ start //latches - rd_m_k_5b
      6'b011000 : begin data_out_5b = 5'b00000; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b100010 : begin data_out_5b = 5'b00001; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b010010 : begin data_out_5b = 5'b00010; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b001010 : begin data_out_5b = 5'b00100; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b000111 : begin data_out_5b = 5'b00111; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b000110 : begin data_out_5b = 5'b01000; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b101000 : begin data_out_5b = 5'b01111; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b100100 : begin data_out_5b = 5'b10000; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b001100 : begin data_out_5b = 5'b11000; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b010100 : begin data_out_5b = 5'b11111; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b1; rd_m_k_5b = 1'b1; end
      6'b000101 : begin data_out_5b = 5'b10111; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end // K RD+ and D RD+ check
      6'b001001 : begin data_out_5b = 5'b11011; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end // K RD+ and D RD+ check
      6'b010001 : begin data_out_5b = 5'b11101; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end // K RD+ and D RD+ check
      6'b100001 : begin data_out_5b = 5'b11110; rd_data = 1'b0; rd_m_data = 1'b1;/**/ d_5b = 1'b1; d_k_5b = 1'b0; rd_m_k_5b = 1'b1; end // K RD+ and D RD+ check
      //Data RD+ end
      //latches - rd_data, rd_m_data, d_k_5b
      6'b001111 : begin data_out_5b = 5'b11100; d_5b = 1'b0; rd_m_k_5b = 1'b1; rd_data = 1'b0; rd_m_data = 1'b1; d_k_5b = 1'b0; end// k symbol RD-
      6'b110000 : begin data_out_5b = 5'b11100; d_5b = 1'b0; rd_m_k_5b = 1'b0; rd_data = 1'b0; rd_m_data = 1'b0; d_k_5b = 1'b0; end// k symbol RD+

      default : begin
                  data_out_5b    = 5'b11100;
                  code_err_temp  = 1'b1;
                  d_5b           = 1'b1;
                  d_k_5b         = 1'b1;
                  rd_data        = 1'b1;
                  rd_m_data      = 1'b1;
                  rd_m_k_5b      = 1'b1;
                end
    endcase

    case(data_in[3:0])
      //RD- Start
      4'b1011 : begin data_out_3b = 3'b000; d_k_3b = 1'b1; rd_m_k = 1'b1; end
      4'b0110 : begin 
                  d_k_3b = 1'b1;
                  disparity_value(d_5b,rd_data,rd_m_data,rd_m_k_5b,3'b001,3'b110,data_out_3b,rd_m_k);
                end
      4'b1010 : begin
                  d_k_3b = 1'b1; 
                  disparity_value(d_5b,rd_data,rd_m_data,rd_m_k_5b,3'b010,3'b101,data_out_3b,rd_m_k);
                end
      4'b1100 : begin data_out_3b = 3'b011; d_k_3b = 1'b1; rd_m_k = 1'b1; end
      4'b1101 : begin data_out_3b = 3'b100; d_k_3b = 1'b1; rd_m_k = 1'b1; end
      4'b0101 : begin
                  d_k_3b = 1'b1; 
                  disparity_value(d_5b,rd_data,rd_m_data,rd_m_k_5b,3'b101,3'b010,data_out_3b,rd_m_k);
                end
      4'b1001 : begin 
                  d_k_3b = 1'b1;
                  disparity_value(d_5b,rd_data,rd_m_data,rd_m_k_5b,3'b110,3'b001,data_out_3b,rd_m_k);
                end
      4'b1110 : begin data_out_3b = 3'b111; d_k_3b = 1'b1; rd_m_k = 1'b1; end //D char
      4'b0111 : begin data_out_3b = 3'b111; d_k_3b = 1'b0; rd_m_k = 1'b1; end //D and K symbol
      //RD+ start
      4'b0100 : begin data_out_3b = 3'b000; d_k_3b = 1'b1; rd_m_k = 1'b0; end
      4'b0011 : begin data_out_3b = 3'b011; d_k_3b = 1'b1; rd_m_k = 1'b0; end
      4'b0010 : begin data_out_3b = 3'b100; d_k_3b = 1'b1; rd_m_k = 1'b0; end
      4'b0001 : begin data_out_3b = 3'b111; d_k_3b = 1'b1; rd_m_k = 1'b0; end //D char
      4'b1000 : begin data_out_3b = 3'b111; d_k_3b = 1'b0; rd_m_k = 1'b0; end //D and K symbol
      default : begin
                  data_out_3b    = 3'b101; //IDLE Char
                  code_err_temp  = 1'b1;
                  d_k_3b         = 1'b0;
                  rd_m_k         = 1'b0;
                end
    endcase
  end

  assign data_rd_p   = rd_data ? (rd_m_k ? 1'b0 : 1'b1) : (rd_m_data ? 1'b0 : 1'b1); //1 - RD+, 0 - RD- for Data Char
  assign k_rd_p      = d_5b ? (d_k_5b ? 1'b0 : (d_k_3b ? 1'b0 : (rd_m_k ? 1'b0 : 1'b1))): (rd_m_k_5b ? 1'b0 : 1'b1); //1 - RD+, 0 - RD- for K Char
  assign disp_err_d  = rdisp_in ? (data_rd_p ? 1'b0 : 1'b1) : (data_rd_p ? 1'b1 : 1'b0);
  assign disp_err_k  = rdisp_in ? (k_rd_p    ? 1'b0 : 1'b1) : (k_rd_p ? 1'b1 : 1'b0);
  
  always@(posedge clk or negedge rst_n) begin
     if (!rst_n) begin
      k_out       <= 1'b0;
      data_out    <= 8'b0;
      disp_err    <= 1'b0;
      code_err    <= 1'b0;
     end

    else begin
      k_out      <=  d_5b ? (d_k_5b ? 1'b0 : (d_k_3b ? 1'b0 : 1'b1)) : 1'b1;
      data_out   <=  {data_out_3b,data_out_5b};
      disp_err   <=  code_err_temp ? 1'b0 : (k_out ? disp_err_k : disp_err_d);
      code_err   <=  code_err_temp;
    end
  end


  task disparity_value (
    input        d_5b_in,
    input        rd_data_in,
    input        rd_m_data_in,
    input        rd_m_k_5b_in,
    input [2:0]  rd_m_in,
    input [2:0]  rd_p_in,
    output [2:0] dataout_3b_out,
    output       rd_m_k_out );
      begin
        if(d_5b_in == 1'b1)
          begin
            if(rd_data_in == 1'b0)
              begin 
                if(rd_m_data_in == 1'b0)
                  begin
                    dataout_3b_out = rd_m_in;
                    rd_m_k_out     = 1'b1;
                  end
                else
                  begin
                    dataout_3b_out = rd_p_in;
                    rd_m_k_out     = 1'b0;
                  end
              end
            else
              begin
                dataout_3b_out = rd_p_in;
                rd_m_k_out     = 1'b0;
              end
          end
        else
          begin
            if(rd_m_k_5b_in == 1'b1)
              begin
                dataout_3b_out = rd_p_in;
                rd_m_k_out     = 1'b0;
              end
            else
              begin
                dataout_3b_out = rd_m_in;
                rd_m_k_out     = 1'b1;
              end
          end
      end
  endtask


endmodule


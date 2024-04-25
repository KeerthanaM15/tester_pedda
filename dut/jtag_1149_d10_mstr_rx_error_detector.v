/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: Jagadeshwaran Karuna                                 *////
////*  Department: CoE                                              *////
////*  Created on: Monday 12 Feb 2024 15:35:00 IST                  *////
////*  Project: IEEE1149.10 IP Design                               *////
////*  Module: jtag_1149_d10_mstr_rx_error_detector                 *////
////*  Submodule: Nil                                               *////
////*  Description: rx path error field detection file              *////
/////////////////////////////////////////////////////////////////////////

`include "defines.vh"
module jtag_1149_d10_mstr_rx_error_detector #(parameter DATA_WIDTH = 8
                                             )
                                            (
                                             input                    clk,
                                             input                    rst_n,
                                             input [DATA_WIDTH-1 : 0] decoded_data,
                                             input                    decoder_k_out,
                                             output reg               error_char_detected
                                            );

  //localparam IDLE_CHAR  = 8'hBC;
  //localparam ERROR_CHAR = 8'hFE;
  
  reg [31:0] decoder_data_buf;

  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          error_char_detected <= 1'b0;
          decoder_data_buf    <= 32'h0000_0000;
        end
      else if((decoded_data == `IDLE_CHAR) && (decoder_k_out == 1'b1))
        begin
          decoder_data_buf <= {decoder_data_buf[23:0], decoded_data};
          if(decoder_data_buf == {32'hFEFEFEFE})
            error_char_detected <= 1'b1;
          else
            error_char_detected <= 1'b0;
        end
      else if((decoded_data == `ERROR_CHAR) && (decoder_k_out == 1'b1))
        begin
          decoder_data_buf <= {decoder_data_buf[23:0], decoded_data};
        end
      else
        begin
          decoder_data_buf    <= 32'h0000_0000;
          error_char_detected <= 1'b0;
        end
    end

endmodule


/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: Jagadeshwaran Karuna                                 *////
////*  Department: CoE                                              *////
////*  Created on: Wednesday 14 Feb 2024 12:45:00 IST               *////
////*  Project: IEEE1149.10 IP Design                               *////
////*  Module: jtag_1149_d10_mstr_rx_flow_ctrl_detector             *////
////*  Submodule: Nil                                               *////
////*  Description: rx path xoff and xon field detection file       *////
/////////////////////////////////////////////////////////////////////////

`include "defines.vh"
module jtag_1149_d10_mstr_rx_flow_ctrl_detector #(parameter DATA_WIDTH = 8
                                                )
                                               (
                                                input                    clk,
                                                input                    rst_n,
                                                input [DATA_WIDTH-1 : 0] decoded_data,
                                                input                    decoder_k_out,
                                                output reg               xoff_detected,
                                                output reg               xon_detected
                                               );

  //localparam IDLE_CHAR  = 8'hBC;
  //localparam XOFF_CHAR  = 8'h7C;
  //localparam XON_CHAR   = 8'h1C;

  reg [31:0]  decoder_data_buf;

  
  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          xoff_detected   <= 1'b0;
          xon_detected    <= 1'b0;
        end
      else if((decoded_data == `IDLE_CHAR) && (decoder_k_out == 1'b1))
        begin
          decoder_data_buf <= {decoder_data_buf[23:0], decoded_data};
          if(decoder_data_buf == {32'h7C7C7C7C})
            xoff_detected <= 1'b1;
          else if(decoder_data_buf == {32'h1C1C1C1C})
            xon_detected  <= 1'b1;
          else
            begin
              xoff_detected  <= 1'b0;
              xon_detected   <= 1'b0;
            end
        end
      else if((decoded_data == `XOFF_CHAR) && (decoder_k_out == 1'b1))
        begin
          decoder_data_buf <= {decoder_data_buf[23:0], decoded_data};
        end
      else if((decoded_data == `XON_CHAR) && (decoder_k_out == 1'b1))
        begin
          decoder_data_buf <= {decoder_data_buf[23:0], decoded_data};
        end
      else
        begin
          decoder_data_buf  <= 32'h0000_0000;
          xoff_detected     <= 1'b0;
          xon_detected      <= 1'b0;
        end
    end

endmodule



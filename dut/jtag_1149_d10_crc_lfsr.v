
/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author    :Divya Nemidoss,divya.nemidoss@tessolve.com        *////
////*  Department: CoE                                              *////
////*  Created on: Wednesday 3 Oct 2023 10:10:00 IST                *////
////*  Project   : IEEE1149.10 IP Design                            *////
////*  Module    : jtag1149_d10_crc_lfsr.v                          *////
////*  Submodule :                                                  *////
////*  Description:                                                 *////
/////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_crc_lfsr (
    input                               clk,         // Clock input
    input                               rst_n,       // Reset input
    input                               data_valid,  // Valid data fetch
    input       [3:0]                   crc_data_be, // CRC data byte enable
    input                               data_eop,    // CRC for one frame has completed
    input       [31:0]                  data,        // Data input (32 bits), Initialize to all zeros
    output wire [31:0]                  crc          // CRC output (32 bits)
);

  parameter polynomial = 32'h04C11DB7;  // CRC32 Polynomial (IEEE 802.3)

  reg [31:0] lfsr;
  reg [31:0] lfsrreg;
  reg [ 5:0] i;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      lfsrreg <= 32'h0000_0000;
    else if
      (data_eop) lfsrreg <= 32'h0000_0000;
    else if
      (data_valid) lfsrreg <= lfsr[31:0];
  end

  always @(*) begin
    lfsr = lfsrreg ^ data;
      case(crc_data_be)
        4'b1111:begin
          for (i = 0; i < 32; i = i+1) begin
            if (lfsr[31]) 
              lfsr = {lfsr[30:0], 1'b0} ^ polynomial;
            else
              lfsr = {lfsr[30:0], 1'b0};
          end
        end
        4'b1110:begin
          for (i = 0; i < 24; i = i+1) begin
            if (lfsr[31])
              lfsr = {lfsr[30:0], 1'b0} ^ polynomial;
            else
              lfsr = {lfsr[30:0], 1'b0};
          end
        end
        4'b1100:begin
          for (i = 0; i < 16; i = i+1) begin
            if (lfsr[31])
              lfsr = {lfsr[30:0], 1'b0} ^ polynomial;
            else
              lfsr = {lfsr[30:0], 1'b0};
          end
        end
        4'b1000:begin
          for (i = 0; i < 8; i = i+1) begin
            if (lfsr[31])
              lfsr = {lfsr[30:0], 1'b0} ^ polynomial;
            else
              lfsr = {lfsr[30:0], 1'b0};
          end
        end
        default : begin
          for (i = 0; i < 32; i = i+1) begin
            if (lfsr[31]) 
              lfsr = {lfsr[30:0], 1'b0} ^ polynomial;
            else
              lfsr = {lfsr[30:0], 1'b0};
          end
        end
      endcase
  end

  assign crc = lfsrreg;

endmodule


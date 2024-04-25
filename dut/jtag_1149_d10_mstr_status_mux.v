/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: rufina.jasni                                         *////
////*  Department: CoE                                              *////
////*  Created on: Wednesday 22 Feb 2024 11:10:00 IST               *////
////*  Project: IEEE1149.10 IP Design                               *////
////*  Module: jtag_1149_d10_mstr_status_mux                        *////
////*  Submodule: Nil                                               *////
////*  Description: Error status flag encode assertion file         *////
/////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_mstr_status_mux
  #(
   parameter DBG_OUT_WIDTH =16
   )
  (
  input                           clk,
  input                           rst_n,
  input                           opcode_error,
  input [1:0]                     eop_error,
  input                           unrecoverable_error,
  input                           lpbk_error,
  input                           scan_rsp_time_out,
  input                           idle_count_error,
  input [3:0]                     dbg_mux_sel,
  output reg [DBG_OUT_WIDTH-1:0]  dbg_mux_out,
  output reg [2:0]                pedda_mst_status1_out
  );

  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      pedda_mst_status1_out <= 3'h0;
    end
    else begin
      case({opcode_error,eop_error,unrecoverable_error,lpbk_error,scan_rsp_time_out,idle_count_error})
        7'b1_00_0_0_0_0 : begin
                          pedda_mst_status1_out <= 3'h1; //op-code
                        end
        7'b0_10_0_0_0_0 : begin
                          pedda_mst_status1_out <= 3'h2; //EOP-Error2
                        end
        7'b0_11_0_0_0_0 : begin
                          pedda_mst_status1_out <= 3'h3; //EOP-Error3
                        end
        7'b0_00_1_0_0_0 : begin
                          pedda_mst_status1_out <= 3'h4; //Unrecoverable
                        end
        7'b0_00_0_1_0_0 : begin
                          pedda_mst_status1_out <= 3'h5; //Loopback error
                        end
        7'b0_00_0_0_1_0 : begin
                          pedda_mst_status1_out <= 3'h6; //Timeout
                        end
        7'b0_00_0_0_0_1 : begin
                          pedda_mst_status1_out <= 3'h7; //Idle count
                        end
              default : begin
                          pedda_mst_status1_out <= 3'h0;
                      end
      endcase
    end
  end

  always@(*) begin
    case(dbg_mux_sel)
      4'b0000 : dbg_mux_out = 16'h0; //TODO
      4'b0001 : dbg_mux_out = 16'h0; //TODO
      4'b0010 : dbg_mux_out = 16'h0; //TODO
      4'b0011 : dbg_mux_out = 16'h0; //TODO
      4'b0100 : dbg_mux_out = 16'h0; //TODO
      4'b0101 : dbg_mux_out = 16'h0; //TODO
      4'b0110 : dbg_mux_out = 16'h0; //TODO
      4'b0111 : dbg_mux_out = 16'h0; //TODO
      4'b1000 : dbg_mux_out = 16'h0; //TODO
      4'b1001 : dbg_mux_out = 16'h0; //TODO
      4'b1010 : dbg_mux_out = 16'h0; //TODO
      4'b1011 : dbg_mux_out = 16'h0; //TODO
      4'b1100 : dbg_mux_out = 16'h0; //TODO
      4'b1101 : dbg_mux_out = 16'h0; //TODO
      4'b1110 : dbg_mux_out = 16'h0; //TODO
      4'b1111 : dbg_mux_out = 16'h0; //TODO
    endcase
  end

endmodule


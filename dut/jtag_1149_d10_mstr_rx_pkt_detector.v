/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: Jagadeshwaran Karuna                                 *////
////*  Department: CoE                                              *////
////*  Created on: Monday 12 Feb 2024 11:15:00 IST                  *////
////*  Project: IEEE1149.10 Tester PEDDA IP Design                  *////
////*  Module: jtag_1149_d10_mstr_rx_pkt_detector                   *////
////*  Submodule:                                                   *////
////*  Description: Decode the respective response packet fields    *////
/////////////////////////////////////////////////////////////////////////


`include "defines.vh"
module jtag_1149_d10_mstr_rx_pkt_detector #(parameter DATA_WIDTH     = 8,
                                           parameter CNT_WIDTH      = 5,
                                           parameter CRC_WIDTH      = 32,
                                           parameter SCAN_WIDTH     = 32,
                                           parameter ERR_CNTR_WIDTH = 16
                                           )
                                          (
                                           input                              clk,
                                           input                              rst_n,
                                           // Decoder interface
                                           input  [DATA_WIDTH-1 : 0]          decoded_data,
                                           input                              decoder_k_out,
                                           // Interface between Rx-to-Tx Ctrl
                                           input                              start_compare,
                                           input  [CNT_WIDTH-1 : 0]           compare_delay,
                                           input  [DATA_WIDTH-1 : 0]          lpbk_src_data,
                                           input  [DATA_WIDTH-1 : 0]          send_pkt_type,
                                           input                              exit_lpbk,
                                           output reg [DATA_WIDTH-6 : 0]      instr_type,
                                           output reg                         rd_nxt_instr,
                                           output reg                         crc_error_detecter,
                                           output reg                         enter_lpbk,
                                           output reg                         sop_detected,
                                           // Interface between Rx-to-CRC
                                           input  [CRC_WIDTH-1 : 0]           crc_result, // CRC checksum data out
                                           output reg                         crc_data_valid,  
                                           output reg [3:0]                   crc_data_be,  
                                           output reg                         crc_data_eop,    
                                           output reg [CRC_WIDTH-1 : 0]       crc_data, // CRC checksum data in    
                                           // Interface between Rx-to-Debug
                                           output reg                         lpbk_error,
                                           output reg                         opcode_error,
                                           output reg                         idle_count_error,
                                           output reg [1:0]                   eop_error,
                                           // Top-level scan response interface
                                           output reg [SCAN_WIDTH-1 : 0]      jtag_1149_d10_mstr_rsp_data,
                                           output reg [SCAN_WIDTH-29 : 0]     jtag_1149_d10_mstr_rsp_data_be,
                                           output reg                         jtag_1149_d10_mstr_rsp_data_vld,
                                           output reg [ERR_CNTR_WIDTH-1 : 0]  jtag_1149_d10_mstr_crc_err_cnt
                                          );
  
  //localparam CONFIGR_CMD    = 8'h81;  // Config response command without parity
  //localparam TARGETR_CMD    = 8'h82;  // Target response command without parity
  //localparam RESETR_CMD     = 8'h83;  // Reset response command without parity
  //localparam RAWR_CMD       = 8'h84;  // RAW response command without parity
  //localparam CH_SELECTR_CMD = 8'h85;  // Ch-Select response command without parity
  //localparam SCANR_CMD      = 8'h86;  // Scan response command without parit
  
  //localparam IDLE_CHAR  = 8'hBC;
  //localparam SOP_CHAR   = 8'hFB;
  //localparam EOP_CHAR   = 8'hFD;

  localparam IDLE_STATE         = 4'd0;
  localparam PKT_DECODE_STATE   = 4'd1;
  localparam CONFIGR_STATE      = 4'd2;
  localparam TARGETR_STATE      = 4'd3;
  localparam RESETR_STATE       = 4'd4;
  localparam RAWR_STATE         = 4'd5;
  localparam CH_SELECTR_STATE   = 4'd6;
  localparam SCANR_STATE        = 4'd7;
  localparam CRC_CHECKSUM_STATE = 4'd8;
  localparam EOP_STATE          = 4'd9;
  localparam CRC_COMPARE_STATE  = 4'd10;
  localparam LPBK_WAIT_STATE    = 4'd11;
  localparam LPBK_COMPARE_STATE = 4'd12;


  //reg [SCAN_WIDTH-1 : 0] lpbk_data_buf;
  reg [3:0]              current_state;
  //reg [3:0]              previous_state;
  reg                    crc_error_valid;
  reg                    send_scan_rsp;
  reg                    scan_rsp_data_in_valid;
  reg [CRC_WIDTH-1 : 0]  crc_data_buf;
  reg [4:0]              byte_count;
  reg [CNT_WIDTH-1 : 0]  lpbk_delay_count;
  reg                    compare_lpbk_data;
  reg [7:0]              pkt_type_buf;
  reg [7:0]              scan_rsp_id;
  reg [7:0]              scan_rsp_icsu;
  reg [31:0]             scan_rsp_payload_frame;
  reg [31:0]             scan_rsp_cycle_count;
  reg [127:0]            scan_rsp_data_buf;
  reg [4:0]              max_payload_count;
  reg [2:0]              max_payload_dword;
  reg [2:0]              scan_tx_count;
  reg [1:0]             idle_count;
  reg [1:0]             eop_count;
  reg [31:0]            crc_result_buf;

  /* verilator lint_off UNUSEDSIGNAL */
  reg [15:0]             target_id_buf;    /* verilator lint_off UNUSEDSIGNAL */
  reg [15:0]             reset_value_buf;  /* verilator lint_off UNUSEDSIGNAL */
  reg [15:0]             raw_value_buf;    /* verilator lint_off UNUSEDSIGNAL */
  reg [47:0]             ch_select_buf;

  //wire                   lpbk_compare_latch;
  wire [15:0]            crc_error_count_incr;
  wire [4:0]             byte_count_incr;
  wire [7:0]             max_payload_bits;


  assign byte_count_incr    = (scan_rsp_data_in_valid) ? (byte_count + 5'd1) : 5'd0;
  //assign lpbk_compare_latch = (previous_state == LPBK_WAIT_STATE && start_compare == 1'b1) ? 1'b1 : 
  //                            ((previous_state != LPBK_WAIT_STATE) ? 1'b0 : lpbk_compare_latch); 

  assign max_payload_bits = ch_select_buf[7:0] * scan_rsp_cycle_count[7:0];                              

  // CRC error counter increment operation
  assign crc_error_count_incr = (crc_error_valid) ? (jtag_1149_d10_mstr_crc_err_cnt + 16'd1) : jtag_1149_d10_mstr_crc_err_cnt;

  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        jtag_1149_d10_mstr_crc_err_cnt <= 16'h0000;
      else
        jtag_1149_d10_mstr_crc_err_cnt <= crc_error_count_incr;
    end

  //always@(posedge clk or negedge rst_n)
  //  begin
  //   if(!rst_n)
  //     lpbk_compare_latch <= 1'b0;
  //   else if(previous_state == LPBK_WAIT_STATE && start_compare == 1'b1)
  //     lpbk_compare_latch <= 1'b1;
  //   else if(previous_state != LPBK_WAIT_STATE)
  //     lpbk_compare_latch <= 1'b0;
  //   else
  //     lpbk_compare_latch <= lpbk_compare_latch;
  //  end

  
  //// This logic used to identify the maximum 
  //// valid payload data's in the incoming packet
  //always@(*)
  //  begin
  //    if(rst_n)
  //      max_payload_bits = 8'd0;
  //    else
  //      max_payload_bits = ch_select_buf[7:0] * scan_rsp_cycle_count[7:0];
  //  end

  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          jtag_1149_d10_mstr_rsp_data     <= {SCAN_WIDTH{1'b0}};
          jtag_1149_d10_mstr_rsp_data_be  <= 4'b0000;
          jtag_1149_d10_mstr_rsp_data_vld <= 1'b0;
          scan_tx_count                   <= 3'd0;
        end
      else if(send_scan_rsp == 1'b0)
        begin
          scan_tx_count  <= 3'd0;
        end
      else if(send_scan_rsp && (scan_tx_count < max_payload_dword))
        begin
          scan_tx_count  <= scan_tx_count + 3'd1;
          if(max_payload_dword == 3'd4)
            begin
              jtag_1149_d10_mstr_rsp_data_vld <= 1'b1;
              if(scan_tx_count == 3'd0)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[127:96];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else if(scan_tx_count == 3'd1)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[95:64];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else if(scan_tx_count == 3'd2)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[63:32];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[31:0];
  //scan response byte enable declaration for last 4-bytes of data's
                  if(max_payload_bits > 8'd96 && max_payload_bits <= 8'd104)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1000;
                  else if(max_payload_bits > 8'd104 && max_payload_bits <= 8'd112)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1100;
                  else if(max_payload_bits > 8'd112 && max_payload_bits <= 8'd120)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1110;
                  else
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1111;
                end
            end
          else if(max_payload_dword == 3'd3)
            begin
              jtag_1149_d10_mstr_rsp_data_vld <= 1'b1;
              if(scan_tx_count == 3'd0)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[95:64];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else if(scan_tx_count == 3'd1)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[63:32];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[31:0];
                  if(max_payload_bits > 8'd64 && max_payload_bits <= 8'd72)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1000;
                  else if(max_payload_bits > 8'd72 && max_payload_bits <= 8'd80)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1100;
                  else if(max_payload_bits > 8'd80 && max_payload_bits <= 8'd88)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1110;
                  else
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1111;
                end
            end
          else if(max_payload_dword == 3'd2)
            begin
              jtag_1149_d10_mstr_rsp_data_vld <= 1'b1;
              if(scan_tx_count == 3'd0)
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[63:32];
                  jtag_1149_d10_mstr_rsp_data_be  <= 4'b1111;
                end
              else
                begin
                  jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[63:32];
                  if(max_payload_bits > 8'd32 && max_payload_bits <= 8'd40)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1000;
                  else if(max_payload_bits > 8'd40 && max_payload_bits <= 8'd48)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1100;
                  else if(max_payload_bits > 8'd48 && max_payload_bits <= 8'd56)
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1110;
                  else
                    jtag_1149_d10_mstr_rsp_data_be <= 4'b1111;
                end
            end
          else
          //else if(max_payload_dword == 3'd1)
            begin
              jtag_1149_d10_mstr_rsp_data     <= scan_rsp_data_buf[31:0];
              jtag_1149_d10_mstr_rsp_data_vld <= 1'b1;
              if(max_payload_bits <= 8'd8)
                jtag_1149_d10_mstr_rsp_data_be <= 4'b1000;
              else if(max_payload_bits > 8'd8 && max_payload_bits <= 8'd16)
                jtag_1149_d10_mstr_rsp_data_be <= 4'b1100;
              else if(max_payload_bits > 8'd16 && max_payload_bits <= 8'd24)
                jtag_1149_d10_mstr_rsp_data_be <= 4'b1110;
              else
                jtag_1149_d10_mstr_rsp_data_be <= 4'b1111;
            end
        end
      else
        begin
          jtag_1149_d10_mstr_rsp_data     <= {SCAN_WIDTH{1'b0}};
          jtag_1149_d10_mstr_rsp_data_be  <= 4'b0000;
          jtag_1149_d10_mstr_rsp_data_vld <= 1'b0;
          scan_tx_count              <= scan_tx_count;
        end
    end

  // Loopback delay counter
  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          lpbk_delay_count   <= {CNT_WIDTH{1'b0}};
          compare_lpbk_data  <= 1'b0; 
        end
      else
        begin
          if(start_compare)
          //if(lpbk_compare_latch)
            begin
              if(lpbk_delay_count == compare_delay)
                begin
                  lpbk_delay_count  <= lpbk_delay_count;
                  //lpbk_delay_count  <= {CNT_WIDTH{1'b0}};
                  compare_lpbk_data <= 1'b1;
                end
              else
                begin
                  lpbk_delay_count  <= lpbk_delay_count + 5'd1;
                  compare_lpbk_data <= 1'b0;
                end
            end
          else
            begin
              lpbk_delay_count  <= {CNT_WIDTH{1'b0}};
              compare_lpbk_data <= 1'b0;
            end
        end
    end

  // Received packet type decoding logic
  always@(*)
    begin
      if(!rst_n)
        instr_type = 3'b000;
      else
        begin
          case(pkt_type_buf)
            8'h81 : instr_type = 3'b001;
            8'h82 : instr_type = 3'b010;
            8'h83 : instr_type = 3'b011;
            8'h84 : instr_type = 3'b100;
            8'h85 : instr_type = 3'b101;
            8'h86 : instr_type = 3'b110;
            default : instr_type = 3'b000;
          endcase
        end
    end

  // Define the maximum payload byte count using payload frame values
  always@(*)
    begin
      if(!rst_n)
        begin
          max_payload_count = 5'd0;
          max_payload_dword = 3'd0;
        end
      else
        begin
          case(scan_rsp_payload_frame[31:24])
            8'h01 : 
               begin
                 max_payload_count = 5'd14;
                 max_payload_dword = 3'd1;
               end
            8'h02 :
               begin
                 max_payload_count = 5'd18;
                 max_payload_dword = 3'd2;
               end
            8'h03 :
               begin
                 max_payload_count = 5'd22;
                 max_payload_dword = 3'd3;
               end
            8'h04 :
               begin
                 max_payload_count = 5'd26;
                 max_payload_dword = 3'd4;
               end
            default :
               begin
                 max_payload_count = 5'd14;
                 max_payload_dword = 3'd1;
               end
          endcase
        end
    end

  //// State updates
  //always@(posedge clk or negedge rst_n)
  //  begin
  //    if(!rst_n)
  //      previous_state <= IDLE_STATE;
  //    else
  //      previous_state <= current_state;
  //  end

  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          //lpbk_data_buf            <= {SCAN_WIDTH{1'b0}};
          crc_error_detecter       <= 1'b0;
          rd_nxt_instr             <= 1'b0;
          enter_lpbk               <= 1'b0;
          crc_data_valid           <= 1'b0;
          crc_data_be              <= 4'd0;
          crc_data_eop             <= 1'b0;
          crc_data                 <= {CRC_WIDTH{1'b0}};
          crc_error_valid          <= 1'b0;
          send_scan_rsp            <= 1'b0;
          crc_data_buf             <= {CRC_WIDTH{1'b0}};
          lpbk_error               <= 1'b0;
          opcode_error             <= 1'b0;
          scan_rsp_data_in_valid   <= 1'b0;
          byte_count               <= 5'd0;
          pkt_type_buf             <= 8'h00;
          target_id_buf            <= 16'h0000;
          reset_value_buf          <= 16'h0000;
          raw_value_buf            <= 16'h0000;
          ch_select_buf            <= 48'd0;
          scan_rsp_id              <= 8'h0;
          scan_rsp_icsu            <= 8'h0;
          scan_rsp_payload_frame   <= 32'h0000;
          scan_rsp_cycle_count     <= 32'h0000;
          scan_rsp_data_buf        <= 128'd0;
          idle_count               <= 2'd0;
          idle_count_error         <= 1'b0;
          sop_detected             <= 1'b0;
          eop_count                <= 2'd0;
          eop_error                <= 2'b00;
          crc_result_buf           <= 32'h0000_0000;
          current_state            <= IDLE_STATE;
        end
      else
        begin
          case(current_state)
            IDLE_STATE :
              begin
                opcode_error            <= 1'b0;
                crc_error_detecter      <= 1'b0;
                scan_rsp_data_in_valid  <= 1'b0;
                byte_count              <= 5'd0;
                crc_data_eop            <= 1'b0;
                crc_error_valid         <= 1'b0;
                crc_data_buf            <= {CRC_WIDTH{1'b0}};
                crc_data                <= {CRC_WIDTH{1'b0}}; 
                //pkt_type_buf            <= 8'h00;
                rd_nxt_instr            <= 1'b0;
                target_id_buf           <= 16'h0000;
                reset_value_buf         <= 16'h0000;
                raw_value_buf           <= 16'h0000;
                ch_select_buf           <= 48'd0;
                scan_rsp_id             <= 8'h0;
                scan_rsp_icsu           <= 8'h0;
                //scan_rsp_payload_frame  <= 32'h0000;
                scan_rsp_cycle_count    <= 32'h0000;
                //scan_rsp_data_buf       <= 128'd0;
                crc_result_buf          <= 32'h0000_0000;
                if(idle_count > 2'd0)
                  begin
                    idle_count      <= idle_count - 2'd1;
                    current_state   <= current_state;
                    if((decoded_data == `IDLE_CHAR) && (decoder_k_out == 1'b1))
                      idle_count_error  <= 1'b0;
                    else
                      idle_count_error  <= 1'b1;
                  end
                else
                  begin
                    idle_count  <= 2'd3;
                    if((decoded_data == `SOP_CHAR) && (decoder_k_out == 1'b1))
                      begin
                        current_state <= PKT_DECODE_STATE;
                        sop_detected  <= 1'b1;
                      end
                    else
                      begin
                        current_state <= current_state;
                        sop_detected  <= 1'b0;
                      end
                  end
              end

            PKT_DECODE_STATE :
              begin
                sop_detected     <= 1'b0;
                //if(decoded_data == `CONFIGR_CMD)
                if(decoded_data == `CONFIGR_CMD && send_pkt_type == `INBD_CFG_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= CONFIGR_STATE;
                  end
                //else if(decoded_data == `TARGETR_CMD)
                else if(decoded_data == `TARGETR_CMD && send_pkt_type == `INBD_TGT_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= TARGETR_STATE;
                  end
                //else if(decoded_data == `RESETR_CMD)
                else if(decoded_data == `RESETR_CMD && send_pkt_type == `INBD_RST_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= RESETR_STATE;
                  end
                //else if(decoded_data == `RAWR_CMD)
                else if(decoded_data == `RAWR_CMD && send_pkt_type == `INBD_RAW_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= RAWR_STATE;
                  end
                //else if(decoded_data == `CH_SELECTR_CMD)
                else if(decoded_data == `CH_SELECTR_CMD && send_pkt_type == `INBD_CHSEL_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= CH_SELECTR_STATE;
                  end
                else if(decoded_data == `SCANR_CMD)
                  begin
                    opcode_error           <= 1'b0;
                    pkt_type_buf           <= decoded_data;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    send_scan_rsp            <= 1'b0;
                    scan_rsp_data_buf      <= 128'd0;
                    current_state          <= SCANR_STATE;
                  end
                else
                  begin
                    opcode_error           <= 1'b1;
                    pkt_type_buf           <= 8'h00;
                    scan_rsp_data_in_valid <= 1'b0;
                    byte_count             <= byte_count;
                    current_state          <= IDLE_STATE;
                  end
              end

            CONFIGR_STATE :
              begin
                if(byte_count_incr < 5'd2)
                  begin
                   crc_data               <= 32'h0000;
                   crc_data_be            <= 4'b0000;
                   crc_data_valid         <= 1'b0;
                   target_id_buf          <= {target_id_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= byte_count_incr;
                   current_state          <= current_state;
                  end
                else
                  begin
                   crc_data               <= {pkt_type_buf, target_id_buf[7:0], decoded_data, 8'h00};
                   crc_data_be            <= 4'b1110;
                   crc_data_valid         <= 1'b1;
                   target_id_buf          <= {target_id_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= 5'd0;
                   current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            TARGETR_STATE :
              begin
                if(byte_count_incr < 5'd2)
                  begin
                   crc_data               <= 32'h0000;
                   crc_data_be            <= 4'b0000;
                   crc_data_valid         <= 1'b0;
                   target_id_buf          <= {target_id_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= byte_count_incr;
                   current_state          <= current_state;
                  end
                else
                  begin
                   crc_data               <= {pkt_type_buf, target_id_buf[7:0], decoded_data, 8'h00};
                   crc_data_be            <= 4'b1110;
                   crc_data_valid         <= 1'b1;
                   target_id_buf          <= {target_id_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= 5'd0;
                   current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            RESETR_STATE :
              begin
                if(byte_count_incr < 5'd2)
                  begin
                   crc_data               <= 32'h0000;
                   crc_data_be            <= 4'b0000;
                   crc_data_valid         <= 1'b0;
                   reset_value_buf        <= {reset_value_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= byte_count_incr;
                   current_state          <= current_state;
                  end
                else
                  begin
                   crc_data               <= {pkt_type_buf, reset_value_buf[7:0], decoded_data, 8'h00};
                   crc_data_be            <= 4'b1110;
                   crc_data_valid         <= 1'b1;
                   reset_value_buf        <= {reset_value_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= 5'd0;
                   current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            RAWR_STATE :
              begin
                if(byte_count_incr < 5'd2)
                  begin
                   crc_data               <= 32'h0000;
                   crc_data_be            <= 4'b0000;
                   crc_data_valid         <= 1'b0;
                   raw_value_buf          <= {raw_value_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= byte_count_incr;
                   current_state          <= current_state;
                  end
                else
                  begin
                   crc_data               <= {pkt_type_buf, raw_value_buf[7:0], decoded_data, 8'h00};
                   crc_data_be            <= 4'b1110;
                   crc_data_valid         <= 1'b1;
                   raw_value_buf          <= {raw_value_buf[7:0], decoded_data};
                   scan_rsp_data_in_valid <= 1'b1;
                   byte_count             <= 5'd0;
                   current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            CH_SELECTR_STATE :
              begin
                if(byte_count_incr < 5'd5)
                  begin
                    crc_data               <= 32'h0000;
                    crc_data_be            <= 4'b0000;
                    crc_data_valid         <= 1'b0;
                    ch_select_buf          <= {ch_select_buf[39:0], decoded_data};
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= current_state;
                  end
                else if(byte_count_incr == 5'd5)
                  begin
                    crc_data               <= {pkt_type_buf, ch_select_buf[31:8]};
                    crc_data_be            <= 4'b1111;
                    crc_data_valid         <= 1'b1;
                    ch_select_buf          <= {ch_select_buf[39:0], decoded_data};
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= current_state;
                  end
                else
                  begin
                    crc_data               <= {ch_select_buf[15:0], decoded_data, 8'h00};
                    //crc_data               <= {ch_select_buf[7:0], scan_rsp_data, 8'h00};
                    crc_data_be            <= 4'b1110;
                    crc_data_valid         <= 1'b1;
                    ch_select_buf          <= {ch_select_buf[39:0], decoded_data};
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= 5'd0;
                    current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            SCANR_STATE :
              begin
                if(byte_count_incr < 5'd11)
                  begin
                    crc_data               <= 32'h0000;
                    crc_data_be            <= 4'b0000;
                    crc_data_valid         <= 1'b0;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    current_state          <= current_state;
                    if(byte_count_incr == 5'd1)
                      scan_rsp_id      <= decoded_data;
                    else if(byte_count_incr == 5'd2)
                      scan_rsp_icsu    <= decoded_data;
                    else if(byte_count_incr > 5'd2 && byte_count_incr < 5'd7)
                      scan_rsp_payload_frame  <= {scan_rsp_payload_frame[23:0], decoded_data};
                    else
                      scan_rsp_cycle_count   <= {scan_rsp_cycle_count[23:0], decoded_data};
                  end
                else if(byte_count_incr > 5'd10 && byte_count_incr < max_payload_count)
                  begin
                    scan_rsp_data_buf      <= {scan_rsp_data_buf[119:0], decoded_data}; 
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= byte_count_incr;
                    //current_state          <= current_state;
                    if(max_payload_count == 5'd26)
                      begin
                        if(byte_count_incr == 5'd20)
                          begin
                            crc_data        <= {pkt_type_buf, scan_rsp_id, scan_rsp_icsu, scan_rsp_payload_frame[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd21)
                          begin
                            crc_data        <= {scan_rsp_payload_frame[23:0], scan_rsp_cycle_count[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd22)
                          begin
                            crc_data        <= {scan_rsp_cycle_count[23:0], scan_rsp_data_buf[87:80]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd23)
                          begin
                            crc_data        <= scan_rsp_data_buf[87:56];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd24)
                          begin
                            crc_data        <= scan_rsp_data_buf[63:32];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd25)
                          begin
                            crc_data        <= scan_rsp_data_buf[39:8];
                            //crc_data        <= scan_rsp_data_buf[40:8];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else
                          begin
                            crc_data        <= crc_data;
                            crc_data_be     <= 4'b0000;
                            crc_data_valid  <= 1'b0;
                            current_state   <= current_state;
                          end
                      end
                    else if(max_payload_count == 5'd22)
                      begin
                        if(byte_count_incr == 5'd17)
                          begin
                            crc_data        <= {pkt_type_buf, scan_rsp_id, scan_rsp_icsu, scan_rsp_payload_frame[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd18)
                          begin
                            crc_data        <= {scan_rsp_payload_frame[23:0], scan_rsp_cycle_count[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd19)
                          begin
                            crc_data        <= {scan_rsp_cycle_count[23:0], scan_rsp_data_buf[63:56]};
                            //crc_data        <= {scan_rsp_cycle_count[23:0], scan_rsp_data_buf[63:54]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd20)
                          begin
                            crc_data        <= scan_rsp_data_buf[63:32];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd21)
                          begin
                            crc_data        <= scan_rsp_data_buf[39:8];
                            //crc_data        <= scan_rsp_data_buf[40:8];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else
                          begin
                            crc_data        <= crc_data;
                            crc_data_be     <= 4'b0000;
                            crc_data_valid  <= 1'b0;
                            current_state   <= current_state;
                          end
                      end
                    else if(max_payload_count == 5'd18)
                      begin
                        if(byte_count_incr == 5'd14)
                          begin
                            crc_data        <= {pkt_type_buf, scan_rsp_id, scan_rsp_icsu, scan_rsp_payload_frame[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd15)
                          begin
                            crc_data        <= {scan_rsp_payload_frame[23:0], scan_rsp_cycle_count[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd16)
                          begin
                            crc_data        <= {scan_rsp_cycle_count[23:0], scan_rsp_data_buf[39:32]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd17)
                          begin
                            crc_data        <= scan_rsp_data_buf[39:8];
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else
                          begin
                            crc_data        <= crc_data;
                            crc_data_be     <= 4'b0000;
                            crc_data_valid  <= 1'b0;
                            current_state   <= current_state;
                          end
                      end
                    else
                      begin
                        if(byte_count_incr == 5'd11)
                          begin
                            crc_data        <= {pkt_type_buf, scan_rsp_id, scan_rsp_icsu, scan_rsp_payload_frame[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd12)
                          begin
                            crc_data        <= {scan_rsp_payload_frame[23:0], scan_rsp_cycle_count[31:24]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                        else if(byte_count_incr == 5'd13)
                          begin
                            crc_data        <= {scan_rsp_cycle_count[23:0], scan_rsp_data_buf[15:8]};
                            crc_data_be     <= 4'b1111;
                            crc_data_valid  <= 1'b1;
                          end
                      end
                  end
                else
                  begin
                    scan_rsp_data_buf      <= {scan_rsp_data_buf[119:0], decoded_data}; 
                    crc_data               <= {scan_rsp_data_buf[15:0], decoded_data, 8'h00};
                    crc_data_be            <= 4'b1110;
                    crc_data_valid         <= 1'b1;
                    scan_rsp_data_in_valid <= 1'b1;
                    byte_count             <= 5'd0;
                    current_state          <= CRC_CHECKSUM_STATE;
                  end
              end

            CRC_CHECKSUM_STATE :
              begin
                crc_data_be      <= 4'b0000;
                crc_data_valid   <= 1'b0;
                crc_error_valid  <= 1'b0;
                send_scan_rsp    <= 1'b0;
                if(byte_count_incr < 5'd4)
                  begin
                    crc_data_buf             <= {crc_data_buf[23:0], decoded_data};
                    scan_rsp_data_in_valid   <= 1'b1;
                    byte_count               <= byte_count_incr;
                    current_state            <= current_state;
                  end
                else
                  begin
                    crc_data_buf             <= {crc_data_buf[23:0], decoded_data};
                    scan_rsp_data_in_valid   <= 1'b1;
                    byte_count               <= 5'd0;
                    current_state            <= EOP_STATE;
                  end
              end

            EOP_STATE :
              begin
                if(byte_count_incr < 5'd4)
                  begin
                    byte_count      <= byte_count_incr;
                    current_state   <= current_state;
                    crc_result_buf    <= {crc_result[7:0], crc_result[15:8], crc_result[23:16], crc_result[31:24]};
                    if((decoded_data == `EOP_CHAR) && (decoder_k_out == 1'b1))
                      eop_count  <= eop_count + 2'd1;
                    else
                      eop_count  <= eop_count;
                  end
                else
                  begin
                     current_state     <= CRC_COMPARE_STATE;
                     crc_data_eop      <= 1'b1;
                     if((decoded_data == `EOP_CHAR) && (decoder_k_out == 1'b1) && (eop_count == 2'd3))
                       begin
                         byte_count    <= 5'd0;
                         eop_count     <= 2'd0;
                         eop_error     <= 2'b00; // NO error
                       end
                     else if((decoded_data == `EOP_CHAR) && (decoder_k_out == 1'b1) && (eop_count == 2'd2))
                       begin
                         byte_count    <= 5'd0;
                         eop_count     <= 2'd0;
                         eop_error     <= 2'b11; // here, only 3-bytes of EOP char is valid
                       end
                     else
                       begin
                         byte_count    <= 5'd0;
                         eop_count     <= 2'd0;
                         eop_error     <= 2'b10; // here, lesser than 3-bytes or if,any data char is present
                       end
                  end
              end

            CRC_COMPARE_STATE :
              begin
                if(crc_data_buf == crc_result_buf)
                  begin
                    crc_error_valid     <= 1'b0;
                    crc_error_detecter  <= 1'b0;
                    if(instr_type == 3'b110 || instr_type == 3'b100)       // Scan packet is not support read next instruction
                      rd_nxt_instr      <= 1'b0;
                    else
                      rd_nxt_instr      <= 1'b1;
                    if(instr_type == 3'b100)
                      begin
                        enter_lpbk    <= 1'b1;
                        current_state <= LPBK_WAIT_STATE;
                      end
                    else if(instr_type == 3'b110)
                      begin
                        send_scan_rsp <= 1'b1;
                        current_state <= IDLE_STATE;
                      end
                    else
                      begin
                        enter_lpbk    <= 1'b0;
                        send_scan_rsp <= 1'b0;
                        current_state <= IDLE_STATE;
                      end
                  end
                else
                  begin
                    crc_error_valid     <= 1'b1;
                    send_scan_rsp       <= 1'b0;
                    rd_nxt_instr        <= 1'b0;
                    crc_error_detecter  <= 1'b1;
                    current_state       <= IDLE_STATE;
                  end
              end

            LPBK_WAIT_STATE :
              begin
                rd_nxt_instr    <= 1'b0;
                if(compare_lpbk_data)
                  current_state <= LPBK_COMPARE_STATE;
                else
                  current_state <= current_state;
              end

            LPBK_COMPARE_STATE :
              begin
                if(!exit_lpbk)
                  begin
                    if(lpbk_src_data == decoded_data)
                      lpbk_error  <= 1'b0;
                    else
                      lpbk_error  <= 1'b1;
                    current_state <= current_state;
                  end
                else
                  begin
                   lpbk_error    <= 1'b0;
                   enter_lpbk    <= 1'b0;
                   current_state <= IDLE_STATE;
                  end
              end
            default :
              begin
                current_state <= IDLE_STATE;
              end
          endcase
        end
    end

  endmodule

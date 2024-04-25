//////////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.               *////
////*  Author: Prabhu Munisamy                                           *////
////*  Department: CoE                                                   *////
////*  Created on: Thursday 07 Mar 2024 19:55:00 IST                     *////
////*  Project: IEEE1149.10 IP Design                                    *////
////*  Module: jtag_1149_d10_mstr_tx_ctrl_top                            *////
////*  Submodule: jtag_1149_d10_mstr_tx_ctrl                             *////
////*             jtag_1149_d10_crc_lfsr                                 *////
////*  Description: Tx controller top module                             *////
//////////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_mstr_tx_ctrl_top
  #(
  //parameter CNT_WIDTH             = 5,
  parameter NIBBLE_WIDTH          = 4,
  parameter BYTE_WIDTH            = 8,
  parameter WORD_WIDTH            = 16,
  parameter D_WORD_WIDTH          = 32
  )
  (
  input                           clk,
  input                           rst_n,
  input                           send_comp_char,
  input                           send_pkt_vld,
  input [BYTE_WIDTH-1:0]          send_pkt_type,
  input [WORD_WIDTH-1:0]          send_target_id,
  input [WORD_WIDTH-1:0]          send_reset_value,
  input [WORD_WIDTH-1:0]          send_raw_value,
  input [BYTE_WIDTH-1:0]          send_ch_sel,
  input [BYTE_WIDTH-1:0]          scan_pkt_id,
  input [NIBBLE_WIDTH-1:0]        scan_pkt_icsu,
  input [NIBBLE_WIDTH-1:0]        scan_pkt_payld_frame,
  input [BYTE_WIDTH-1:0]          scan_pkt_cycle_count,
  
  input                           test_ptrn_data_vld,
  input [D_WORD_WIDTH-1:0]        test_ptrn_data,
  input                           test_ptrn_data_last,
  input                           ptrn_end,
  
  input                           enter_lpbk,
  input                           raw_data_vld,
  input [D_WORD_WIDTH-1:0]        raw_data_in,
  input                           exit_lpbk_mode,
  output wire                     read_next_loc,
  output wire                     pkt_txm_done,
  output wire                     comp_char_done,

  input                           rd_nxt_instr,
 // input [BYTE_WIDTH-6 : 0]        instr_type,
  input                           instr_retry,
  input                           suspend_xmission,
  output wire                     start_compare,
  output wire                     lpbk_data_vld,
  output wire [BYTE_WIDTH-1 : 0]  lpbk_src_data,
  output wire                     raw_lpbk_entered,

  output wire                     scan_pyld_read_en,

  output wire [BYTE_WIDTH-1:0]    data_enc,
  output wire                     encoder_k_out
  );

  wire  [D_WORD_WIDTH-1:0]        crc_data_out;
  wire  [D_WORD_WIDTH-1:0]        crc_data_in;
  wire  [NIBBLE_WIDTH-1:0]        crc_data_be;
  wire                            crc_data_vld;
  wire                            crc_data_eop;

  jtag_1149_d10_crc_lfsr crc_lfsr
  (
  .clk                         (  clk                    ),
  .rst_n                       (  rst_n                  ),
  .data_valid                  (  crc_data_vld           ),
  .crc_data_be                 (  crc_data_be            ),
  .data_eop                    (  crc_data_eop           ),
  .data                        (  crc_data_in            ),
  .crc                         (  crc_data_out           )
  );

  jtag_1149_d10_mstr_tx_ctrl
  #(
  .NIBBLE_WIDTH                (  NIBBLE_WIDTH           ),
  .BYTE_WIDTH                  (  BYTE_WIDTH             ),
  .WORD_WIDTH                  (  WORD_WIDTH             ),
  .D_WORD_WIDTH                (  D_WORD_WIDTH           )
  ) mstr_tx_ctrl
  (
  .clk                         (  clk                    ),
  .rst_n                       (  rst_n                  ),
  .send_comp_char              (  send_comp_char         ),
  .send_pkt_vld                (  send_pkt_vld           ),
  .send_pkt_type               (  send_pkt_type          ),
  .send_target_id              (  send_target_id         ),
  .send_reset_value            (  send_reset_value       ),
  .send_raw_value              (  send_raw_value         ),
  .send_ch_sel                 (  send_ch_sel            ),
  .scan_pkt_id                 (  scan_pkt_id            ),
  .scan_pkt_icsu               (  scan_pkt_icsu          ),
  .scan_pkt_payld_frame        (  scan_pkt_payld_frame   ),
  .scan_pkt_cycle_count        (  scan_pkt_cycle_count   ),
  .test_ptrn_data_vld          (  test_ptrn_data_vld     ),
  .test_ptrn_data              (  test_ptrn_data         ),
  .test_ptrn_data_last         (  test_ptrn_data_last    ),
  .ptrn_end                    (  ptrn_end               ),
  .enter_lpbk                  (  enter_lpbk             ),
  .raw_data_vld                (  raw_data_vld           ),
  .raw_data_in                 (  raw_data_in            ),
  .exit_lpbk_mode              (  exit_lpbk_mode         ),
  .read_next_loc               (  read_next_loc          ),
  .pkt_txm_done                (  pkt_txm_done           ),
  .comp_char_done              (  comp_char_done         ),
  .rd_nxt_instr                (  rd_nxt_instr           ),
  //.instr_type                  (  instr_type             ),
  .instr_retry                 (  instr_retry            ),
  .suspend_xmission            (  suspend_xmission       ),
  .start_compare               (  start_compare          ),
  .lpbk_data_vld               (  lpbk_data_vld          ),
  .lpbk_src_data               (  lpbk_src_data          ),
  .raw_lpbk_entered            (  raw_lpbk_entered       ),
  .crc_data_out                (  crc_data_out           ),
  .crc_data_in                 (  crc_data_in            ),
  .crc_data_be                 (  crc_data_be            ),
  .crc_data_vld                (  crc_data_vld           ),
  .crc_data_eop                (  crc_data_eop           ),
  .scan_pyld_read_en           (  scan_pyld_read_en      ),
  .data_enc                    (  data_enc               ),
  .encoder_k_out               (  encoder_k_out          )
   );

endmodule


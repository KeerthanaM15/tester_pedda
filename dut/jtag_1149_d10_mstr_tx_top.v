/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: prabhu.munisamy,rufina.jasni                         *////
////*  Department: CoE                                              *////
////*  Created on: Monday 07 Mar 2024 04:25:00 IST                  *////
////*  Project: IEEE1149.10 IP Design                               *////
////*  Module: jtag_1149_d10_mstr_tx_top                            *////
////*  Submodule: jtag_1149_d10_mstr_tx_ctrl_top, encoder_8b10b,    *////
////*             jtag_1149_d10_mstr_sram_rd_ctrl                   *////
////*  Description: Master PEDDA tx_top module                      *////
/////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_mstr_tx_top
  #(
  parameter SRAMD_WIDTH           = 32,
  parameter SRAMA_WIDTH           = 10,
  parameter CH_SEL_WIDTH          = 8,
  parameter NIBBLE_WIDTH          = 4,
  parameter BYTE_WIDTH            = 8,
  parameter WORD_WIDTH            = 16,
  parameter D_WORD_WIDTH          = 32
  )
  (
  input                          clk,
  input                          rst_n,
  //SRAM Interface signals
  input [SRAMD_WIDTH-1:0]        sram_rd_data,
  output wire                    sram_we,
  output wire[SRAMA_WIDTH-1:0]   sram_addr,
  output wire[SRAMD_WIDTH-1:0]   sram_wr_data,
  //Tx-to-Rx controller Interface signals
  input                          enter_lpbk,
  input                          rd_nxt_instr,
  input                          instr_retry,
  input                          suspend_xmission,
  output wire                    exit_lpbk_mode,
  output wire                    pkt_txm_done,
  output wire                    start_compare,
  output wire                    lpbk_data_vld,
  output wire [BYTE_WIDTH-1 : 0] lpbk_src_data,
  output wire [BYTE_WIDTH-1:0]   send_pkt_type,
  //Top-level Interface signal
  output wire [10-1:0]           jtag_1149_d10_mstr_data_out
  );

  wire                           scan_pyld_read_en;
  wire                           start_op_dtctd;
  wire                           send_pkt_vld;
  //wire [BYTE_WIDTH-1:0]          send_pkt_type;
  wire [WORD_WIDTH-1:0]          send_target_id;
  wire [WORD_WIDTH-1:0]          send_reset_value;
  wire [WORD_WIDTH-1:0]          send_raw_value;
  wire [BYTE_WIDTH-1:0]          send_ch_sel;
  wire [BYTE_WIDTH-1:0]          scan_pkt_id;
  wire [NIBBLE_WIDTH-1:0]        scan_pkt_icsu;
  wire [NIBBLE_WIDTH-1:0]        scan_pkt_payld_frame;
  wire [BYTE_WIDTH-1:0]          scan_pkt_cycle_count;
  wire                           test_ptrn_data_vld;
  wire [D_WORD_WIDTH-1:0]        test_ptrn_data;
  wire                           test_ptrn_data_last;
  wire                           unused__ptrn_end;  
  //wire                         ptrn_end;  
  wire                           raw_data_vld;
  wire [SRAMD_WIDTH-1:0]         send_raw_data;
  wire                           read_next_loc;
  wire                           comp_char_done;
 // input [BYTE_WIDTH-6 : 0]     instr_type;
  wire                           raw_lpbk_entered;
  wire [BYTE_WIDTH-1:0]          data_in_enc;
  wire                           encoder_k_out;
  wire                           unused__k_err;
  
  

  jtag_1149_d10_mstr_tx_ctrl_top
  #(
  .NIBBLE_WIDTH                (  NIBBLE_WIDTH           ),
  .BYTE_WIDTH                  (  BYTE_WIDTH             ),
  .WORD_WIDTH                  (  WORD_WIDTH             ),
  .D_WORD_WIDTH                (  D_WORD_WIDTH           )
  ) i_mstr_tx_ctrl_top
  (
  .clk                         (  clk                    ),
  .rst_n                       (  rst_n                  ),
  .send_comp_char              (  start_op_dtctd         ),
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
  //.ptrn_end                    (  ptrn_end               ),
  .enter_lpbk                  (  enter_lpbk             ),
  .raw_data_vld                (  raw_data_vld           ),
  .raw_data_in                 (  send_raw_data          ),
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
  .scan_pyld_read_en           (  scan_pyld_read_en      ),
  .data_enc                    (  data_in_enc            ),
  .encoder_k_out               (  encoder_k_out          )
   );

  encoder_8b10b i_mstr_encoder
  (
  .clk                         (  clk                         ),
  .rst_n                       (  rst_n                       ),
  .k_in                        (  encoder_k_out               ),
  .data_in                     (  data_in_enc                 ),
  .k_err                       (  unused__k_err               ),
  .data_out                    (  jtag_1149_d10_mstr_data_out )
  );

   jtag_1149_d10_mstr_sram_rd_ctrl
  #(
  .SRAMD_WIDTH                 (  SRAMD_WIDTH            ),
  .SRAMA_WIDTH                 (  SRAMA_WIDTH            ),
  .CH_SEL_WIDTH                (  CH_SEL_WIDTH           ),
  .BYTE_WIDTH                  (  BYTE_WIDTH             ),
  .WORD_WIDTH                  (  WORD_WIDTH             ),
  .NIBBLE_WIDTH                (  NIBBLE_WIDTH           )
  ) i_mstr_sram_rd_ctrl
  (
  .clk                         (  clk                    ),
  .rst_n                       (  rst_n                  ),
  .sram_addr                   (  sram_addr              ),
  .sram_rd_data                (  sram_rd_data           ),
  .sram_we                     (  sram_we                ),
  .sram_wr_data                (  sram_wr_data           ),
  .read_next_loc               (  read_next_loc          ),
  .comp_char_done              (  comp_char_done         ),
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
  .scan_instr_processed        (  scan_pyld_read_en      ),
  .test_ptrn_data_vld          (  test_ptrn_data_vld     ),
  .test_ptrn_data              (  test_ptrn_data         ),
  .test_ptrn_data_last         (  test_ptrn_data_last    ),
  .enter_lpbk                  (  raw_lpbk_entered       ),
  .raw_data_vld                (  raw_data_vld           ),
  .send_raw_data               (  send_raw_data          ),
  .exit_lpbk_mode              (  exit_lpbk_mode         ),
  .ptrn_end                    (  unused__ptrn_end       ),
  //.ptrn_end                    (  ptrn_end               ),
  .start_op_dtctd              (  start_op_dtctd         )
  );


endmodule

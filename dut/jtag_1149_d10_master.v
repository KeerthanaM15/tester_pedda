/////////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.              *////
////*  Author: prabhu.munisamy,jagadeshwaran.karuna,rufina.jasni        *////
////*  Department: CoE                                                  *////
////*  Created on: Monday 07 Mar 2024 04:25:00 IST                      *////
////*  Project: IEEE1149.10 IP Design                                   *////
////*  Module: jtag_1149_d10_master                                     *////
////*  Submodule: jtag_1149_d10_mstr_rx_top, jtag_1149_d10_mstr_tx_top  *////
////*             jtag_1149_d10_mstr_status_mux                         *////
////*  Description: Master PEDDA top module                             *////
/////////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_master
  #(
  parameter SRAMD_WIDTH        = 32,
  parameter SRAMA_WIDTH        = 10,
  parameter CH_SEL_WIDTH       = 8,
  parameter DATA_WIDTH         = 8,
  parameter CNT_WIDTH          = 5,
  parameter CRC_WIDTH          = 32,
  parameter SCAN_WIDTH         = 32,
  parameter ENC_DATA_WIDTH     = 10,
  parameter ERR_CNTR_WIDTH     = 16,
  parameter NIBBLE_WIDTH       = 4,
  parameter BYTE_WIDTH         = 8,
  parameter WORD_WIDTH         = 16,
  parameter D_WORD_WIDTH       = 32,
  parameter DBG_OUT_WIDTH      = 16
  )
  (
  input                               clk,
  input                               rst_n,
  //Top signals start
  input [SRAMD_WIDTH-1:0]             sram_rd_data,
  output wire                         sram_we,
  output wire[SRAMA_WIDTH-1:0]        sram_addr,
  output wire[SRAMD_WIDTH-1:0]        sram_wr_data,
  //RX ctrl signals
  input [ENC_DATA_WIDTH-1 : 0]        jtag_1149_d10_mstr_data_in,
  input  [CNT_WIDTH-1 : 0]            compare_delay, //TODO from top
  output wire [SCAN_WIDTH-1 : 0]      jtag_1149_d10_mstr_rsp_data,
  output wire [SCAN_WIDTH-29 : 0]     jtag_1149_d10_mstr_rsp_data_be,
  output wire                         jtag_1149_d10_mstr_rsp_data_vld,
  output wire [ERR_CNTR_WIDTH-1 : 0]  jtag_1149_d10_mstr_crc_err_cnt,
  //TX ctrl signals
  output wire [10-1:0]                jtag_1149_d10_mstr_data_out,
  //Debugg mux signals
  input [3:0]                         dbg_mux_sel,
  output wire [DBG_OUT_WIDTH-1:0]     dbg_mux_out,
  output wire [2:0]                   pedda_mst_status1_out
  );
  
  //TODO debug interface starts
  wire                         lpbk_error;
  wire                         opcode_error;
  wire                         unrecoverable_error;
  wire                         scan_rsp_time_out;
  wire                         idle_count_error;
  wire [1:0]                   eop_error;
  wire [DATA_WIDTH-6 : 0]      unused__instr_type;
  wire                         unused__lpbk_data_vld;

  wire                         start_compare;
  wire [BYTE_WIDTH-1 : 0]      lpbk_src_data;
  wire                         pkt_txm_done;
  wire                         rd_nxt_instr;
  wire                         instr_retry;
  wire                         enter_lpbk;
  wire                         suspend_xmission;
  wire                         exit_lpbk_mode;
  wire [BYTE_WIDTH-1:0]        send_pkt_type;


  jtag_1149_d10_mstr_rx_top
  #(
  .DATA_WIDTH                        (  DATA_WIDTH                       ),
  .CNT_WIDTH                         (  CNT_WIDTH                        ),
  .CRC_WIDTH                         (  CRC_WIDTH                        ),
  .SCAN_WIDTH                        (  SCAN_WIDTH                       ),
  .ENC_DATA_WIDTH                    (  ENC_DATA_WIDTH                   ),
  .ERR_CNTR_WIDTH                    (  ERR_CNTR_WIDTH                   )
  ) i_mstr_rx_top
  (
  .clk                               (  clk                              ),
  .rst_n                             (  rst_n                            ),
  .jtag_1149_d10_mstr_data_in        (  jtag_1149_d10_mstr_data_in       ),
  .start_compare                     (  start_compare                    ),
  .compare_delay                     (  compare_delay                    ),
  .lpbk_src_data                     (  lpbk_src_data                    ),
  .exit_lpbk                         (  exit_lpbk_mode                   ),
  .send_pkt                          (  pkt_txm_done                     ),
  .send_pkt_type                     (  send_pkt_type                    ),
  .instr_type                        (  unused__instr_type               ),
  .rd_nxt_instr                      (  rd_nxt_instr                     ),
  .instr_retry                       (  instr_retry                      ),
  .enter_lpbk                        (  enter_lpbk                       ),
  .suspend_xmission                  (  suspend_xmission                 ),
  .lpbk_error                        (  lpbk_error                       ),
  .opcode_error                      (  opcode_error                     ),
  .unrecoverable_error               (  unrecoverable_error              ),
  .scan_rsp_time_out                 (  scan_rsp_time_out                ),
  .idle_count_error                  (  idle_count_error                 ),
  .eop_error                         (  eop_error                        ),
  .jtag_1149_d10_mstr_rsp_data       (  jtag_1149_d10_mstr_rsp_data      ),
  .jtag_1149_d10_mstr_rsp_data_be    (  jtag_1149_d10_mstr_rsp_data_be   ),
  .jtag_1149_d10_mstr_rsp_data_vld   (  jtag_1149_d10_mstr_rsp_data_vld  ),
  .jtag_1149_d10_mstr_crc_err_cnt    (  jtag_1149_d10_mstr_crc_err_cnt   )
  );

  jtag_1149_d10_mstr_tx_top
  #(
  .NIBBLE_WIDTH                     (  NIBBLE_WIDTH          ),
  .BYTE_WIDTH                       (  BYTE_WIDTH            ),
  .WORD_WIDTH                       (  WORD_WIDTH            ),
  .CH_SEL_WIDTH                     (  CH_SEL_WIDTH          ),
  .D_WORD_WIDTH                     (  D_WORD_WIDTH          )
  ) i_mstr_tx_top
  (
  .clk                              (  clk                           ),
  .rst_n                            (  rst_n                         ),
  .sram_addr                        (  sram_addr                     ),
  .sram_rd_data                     (  sram_rd_data                  ),
  .sram_we                          (  sram_we                       ),
  .sram_wr_data                     (  sram_wr_data                  ),
  .enter_lpbk                       (  enter_lpbk                    ),
  .exit_lpbk_mode                   (  exit_lpbk_mode                ),
  .pkt_txm_done                     (  pkt_txm_done                  ),
  .rd_nxt_instr                     (  rd_nxt_instr                  ),
  .instr_retry                      (  instr_retry                   ),
  .suspend_xmission                 (  suspend_xmission              ),
  .start_compare                    (  start_compare                 ),
  .lpbk_data_vld                    (  unused__lpbk_data_vld         ),
  .lpbk_src_data                    (  lpbk_src_data                 ),
  .send_pkt_type                    (  send_pkt_type                 ),
  .jtag_1149_d10_mstr_data_out      (  jtag_1149_d10_mstr_data_out   )
  );

  jtag_1149_d10_mstr_status_mux
  #(
   .DBG_OUT_WIDTH  (  DBG_OUT_WIDTH  ) 
   ) i_mstr_status_mux
  (
  .clk                     (  clk                   ),
  .rst_n                   (  rst_n                 ),
  .opcode_error            (  opcode_error          ),
  .eop_error               (  eop_error             ),
  .unrecoverable_error     (  unrecoverable_error   ),
  .lpbk_error              (  lpbk_error            ),
  .scan_rsp_time_out       (  scan_rsp_time_out     ),
  .idle_count_error        (  idle_count_error      ),
  .dbg_mux_sel             (  dbg_mux_sel           ),
  .dbg_mux_out             (  dbg_mux_out           ),
  .pedda_mst_status1_out   (  pedda_mst_status1_out )
  );

endmodule

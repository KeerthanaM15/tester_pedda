//////////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.               *////
////*  Author: Jagadeshwaran Karuna                                      *////
////*  Department: CoE                                                   *////
////*  Created on: Mondday 19 Feb 2024 12:55:00 IST                      *////
////*  Project: IEEE1149.10 IP Design                                    *////
////*  Module: jtag_1149_d10_mstr_rx_top                                 *////
////*  Submodule: jtag_1149_d10_mstr_rx_ctrl_top,                        *////
////*             decoding_10b8b,  jtag_1149_d10_crc_lfsr                *////
////*  Description: Rx controller wrapper module                         *////
//////////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_mstr_rx_top  #(parameter DATA_WIDTH     = 8,
                                    parameter CNT_WIDTH      = 5,
                                    parameter CRC_WIDTH      = 32,
                                    parameter SCAN_WIDTH     = 32,
                                    parameter ENC_DATA_WIDTH = 10,
                                    parameter ERR_CNTR_WIDTH = 16
                                   )
                                  (
                                   input                              clk,
                                   input                              rst_n,
                                   input [ENC_DATA_WIDTH-1 : 0]       jtag_1149_d10_mstr_data_in,
                                   // Interface between Rx-to-Tx Ctrl
                                   input                              start_compare,
                                   input  [CNT_WIDTH-1 : 0]           compare_delay,
                                   input  [DATA_WIDTH-1 : 0]          lpbk_src_data,
                                   input                              exit_lpbk,
                                   input                              send_pkt,
                                   input  [DATA_WIDTH-1 : 0]          send_pkt_type,
                                   output wire [DATA_WIDTH-6 : 0]     instr_type,
                                   output wire                        rd_nxt_instr,
                                   output wire                        instr_retry,
                                   output wire                        enter_lpbk,
                                   output wire                        suspend_xmission,
                                   // Interface between Rx-to-Debug
                                   output wire                        lpbk_error,
                                   output wire                        opcode_error,
                                   output wire                        unrecoverable_error,
                                   output wire                        scan_rsp_time_out,
                                   output wire                        idle_count_error,
                                   output wire [1:0]                  eop_error,
                                   // Top-level scan response interface
                                   output wire [SCAN_WIDTH-1 : 0]     jtag_1149_d10_mstr_rsp_data,
                                   output wire [SCAN_WIDTH-29 : 0]    jtag_1149_d10_mstr_rsp_data_be,
                                   output wire                        jtag_1149_d10_mstr_rsp_data_vld,
                                   output wire [ERR_CNTR_WIDTH-1 : 0] jtag_1149_d10_mstr_crc_err_cnt
                                  );


  wire [DATA_WIDTH-1 : 0]       decoded_data;
  wire                          decoder_k_out;
  wire [CRC_WIDTH-1 : 0]        crc_result;
  wire                          crc_data_valid;  
  wire [3:0]                    crc_data_be;  
  wire                          crc_data_eop;    
  wire [CRC_WIDTH-1 : 0]        crc_data_in;

  wire                          unused__code_err; //invalid data received //unused
  wire                          unused__disp_err; //disparity Error //unused
                                  
  jtag_1149_d10_mstr_rx_ctrl_top #(
                                   .DATA_WIDTH      (DATA_WIDTH      ), 
                                   .CNT_WIDTH       (CNT_WIDTH       ), 
                                   .CRC_WIDTH       (CRC_WIDTH       ), 
                                   .SCAN_WIDTH      (SCAN_WIDTH      ),
                                   .ERR_CNTR_WIDTH  (ERR_CNTR_WIDTH  )
                                  )
              i_mstr_rx_ctrl_top (
                                  .clk                               (clk                               ),
                                  .rst_n                             (rst_n                             ),
                                  .decoded_data                      (decoded_data                      ),
                                  .decoder_k_out                     (decoder_k_out                     ),
                                  .start_compare                     (start_compare                     ),
                                  .compare_delay                     (compare_delay                     ),
                                  .lpbk_src_data                     (lpbk_src_data                     ),
                                  .exit_lpbk                         (exit_lpbk                         ),
                                  .send_pkt                          (send_pkt                          ),
                                  .send_pkt_type                     (send_pkt_type                     ),
                                  .instr_type                        (instr_type                        ),
                                  .rd_nxt_instr                      (rd_nxt_instr                      ),
                                  .instr_retry                       (instr_retry                       ),
                                  .enter_lpbk                        (enter_lpbk                        ),
                                  .suspend_xmission                  (suspend_xmission                  ),
                                  .crc_result                        (crc_result                        ),
                                  .crc_data_valid                    (crc_data_valid                    ),  
                                  .crc_data_be                       (crc_data_be                       ),  
                                  .crc_data_eop                      (crc_data_eop                      ),    
                                  .crc_data_in                       (crc_data_in                       ),
                                  .lpbk_error                        (lpbk_error                        ),
                                  .opcode_error                      (opcode_error                      ),
                                  .unrecoverable_error               (unrecoverable_error               ),
                                  .scan_rsp_time_out                 (scan_rsp_time_out                 ),
                                  .idle_count_error                  (idle_count_error                  ),
                                  .eop_error                         (eop_error                         ),
                                  .jtag_1149_d10_mstr_rsp_data       (jtag_1149_d10_mstr_rsp_data       ),
                                  .jtag_1149_d10_mstr_rsp_data_be    (jtag_1149_d10_mstr_rsp_data_be    ),
                                  .jtag_1149_d10_mstr_rsp_data_vld   (jtag_1149_d10_mstr_rsp_data_vld   ),
                                  .jtag_1149_d10_mstr_crc_err_cnt    (jtag_1149_d10_mstr_crc_err_cnt    )
                                 );

  jtag_1149_d10_crc_lfsr 
       i_mst_rx_crc_lfsr(
                         .clk           (clk             ),
                         .rst_n         (rst_n           ),
                         .data_valid    (crc_data_valid  ),
                         .crc_data_be   (crc_data_be     ),
                         .data_eop      (crc_data_eop    ),
                         .data          (crc_data_in     ),
                         .crc           (crc_result      )
                        );

  decoding_10b8b 
   i_mst_decoder(
                 .clk         (clk                          ),
                 .rst_n       (rst_n                        ),
                 .data_in     (jtag_1149_d10_mstr_data_in   ),
                 .rdisp_in    (1'b0                         ), // There is no disparity check
                 .code_err    (unused__code_err             ),
                 .disp_err    (unused__disp_err             ),
                 .k_out       (decoder_k_out                ),
                 .data_out    (decoded_data                 )
                );

endmodule                                  

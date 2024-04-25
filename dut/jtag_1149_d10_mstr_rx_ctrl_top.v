//////////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.               *////
////*  Author: Jagadeshwaran Karuna                                      *////
////*  Department: CoE                                                   *////
////*  Created on: Monday 19 Feb 2024 11:00:00 IST                       *////
////*  Project: IEEE1149.10 IP Design                                    *////
////*  Module: jtag_1149_d10_mstr_rx_ctrl_top                            *////
////*  Submodule: jtag_1149_d10_mstr_rx_pkt_detector,                    *////
////*             jtag_1149_d10_mstr_rx_error_detector,flow_ctrl_detector*////
////*  Description: Rx controller module                                 *////
//////////////////////////////////////////////////////////////////////////////

module jtag_1149_d10_mstr_rx_ctrl_top #(parameter DATA_WIDTH     = 8,
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
                                       input                              exit_lpbk,
                                       input                              send_pkt,
                                       input  [DATA_WIDTH-1 : 0]          send_pkt_type,
                                       output wire [DATA_WIDTH-6 : 0]     instr_type,
                                       output wire                        rd_nxt_instr,
                                       output wire                        enter_lpbk,
                                       output reg                         instr_retry,
                                       output reg                         suspend_xmission,
                                       // Interface between Rx-to-CRC
                                       input  [CRC_WIDTH-1 : 0]           crc_result, // CRC checksum data out
                                       output wire                        crc_data_valid,  
                                       output wire [3:0]                  crc_data_be,  
                                       output wire                        crc_data_eop,    
                                       output wire [CRC_WIDTH-1 : 0]      crc_data_in, // CRC checksum data in    
                                       // Interface between Rx-to-Debug
                                       output wire                        lpbk_error,
                                       output wire                        opcode_error,
                                       output wire                        idle_count_error,
                                       output wire [1:0]                  eop_error,
                                       output reg                         unrecoverable_error,
                                       output reg                         scan_rsp_time_out,
                                       // Top-level scan response interface
                                       output wire [SCAN_WIDTH-1 : 0]     jtag_1149_d10_mstr_rsp_data,
                                       output wire [SCAN_WIDTH-29 : 0]    jtag_1149_d10_mstr_rsp_data_be,
                                       output wire                        jtag_1149_d10_mstr_rsp_data_vld,
                                       output wire [ERR_CNTR_WIDTH-1 : 0] jtag_1149_d10_mstr_crc_err_cnt
                                      );

  localparam IDLE_STATE  = 1'b0;
  localparam COUNT_STATE = 1'b1;
  
   wire     error_char_detected;
   wire     crc_error_detecter;
   wire     xoff_detected;
   wire     xon_detected;
   wire     sop_detected;
  
   reg       time_out_state;
   reg [2:0] retry_count;
   reg [9:0] time_out_count;
  

  // This below logic excecute the retry operation with the maximum
  // retry attempt and unrecoverable error state logic
  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          retry_count          <= 3'd0;
          instr_retry          <= 1'b0;
          unrecoverable_error  <= 1'b0;
        end
      else
        begin
          if((retry_count < 3'd4) && (error_char_detected || crc_error_detecter))
            begin
              retry_count  <= retry_count + 3'd1;
              instr_retry  <= 1'b1;
            end
          else if((retry_count > 3'd0) && rd_nxt_instr)
            begin
              retry_count          <= 3'd0;
              instr_retry          <= 1'b0;
              unrecoverable_error  <= 1'b0;
            end
          else if(retry_count > 3'd3)
            begin
              retry_count          <= 3'd0;
              unrecoverable_error  <= 1'b1;
            end
          else
            begin
              retry_count          <= retry_count;
              instr_retry          <= 1'b0;
              unrecoverable_error  <= 1'b0;
            end
        end
    end

  // This below logic excecute the Transmission Flow control
  // or Transmission Suspend operation
  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        suspend_xmission <= 1'b0;
      else
        begin
          if(xoff_detected)
            suspend_xmission <= 1'b1;
          else if(xon_detected)
            suspend_xmission <= 1'b0;
          else
            suspend_xmission <= suspend_xmission;
        end
    end

  // This below logic excecute the Timeout operation
  // of Master PEDDA packet transmission
  always@(posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          scan_rsp_time_out  <= 1'b0;
          time_out_count     <= 10'd0;
          time_out_state     <= IDLE_STATE;
        end
      else
        begin
          case(time_out_state)
            IDLE_STATE :
              begin
                scan_rsp_time_out  <= 1'b0;
                time_out_count     <= 10'd0;
                if(send_pkt)
                  time_out_state   <= COUNT_STATE;
                else
                  time_out_state   <= IDLE_STATE;
              end
            COUNT_STATE :
              begin
                if(time_out_count < 10'd1000)
                  begin
                    scan_rsp_time_out  <= 1'b0;
                    time_out_count     <= time_out_count + 10'd1;
                    if(sop_detected || error_char_detected)
                      time_out_state   <= IDLE_STATE;
                    else
                      time_out_state   <= COUNT_STATE;
                  end
                else
                  begin
                    scan_rsp_time_out  <= 1'b1;
                    time_out_count     <= 10'd0;
                    time_out_state     <= IDLE_STATE;
                  end
              end
          endcase
        end
    end


  jtag_1149_d10_mstr_rx_pkt_detector #(
                                      .DATA_WIDTH      (DATA_WIDTH      ), 
                                      .CNT_WIDTH       (CNT_WIDTH       ), 
                                      .CRC_WIDTH       (CRC_WIDTH       ), 
                                      .SCAN_WIDTH      (SCAN_WIDTH      ),
                                      .ERR_CNTR_WIDTH  (ERR_CNTR_WIDTH  )
                                      )
               i_mstr_rx_pkt_detector (
                                      .clk                               (clk                              ),
                                      .rst_n                             (rst_n                            ),
                                      .decoded_data                      (decoded_data                     ),
                                      .decoder_k_out                     (decoder_k_out                    ),
                                      .start_compare                     (start_compare                    ),
                                      .compare_delay                     (compare_delay                    ),
                                      .lpbk_src_data                     (lpbk_src_data                    ),
                                      .send_pkt_type                     (send_pkt_type                    ),
                                      .exit_lpbk                         (exit_lpbk                        ),
                                      .instr_type                        (instr_type                       ),
                                      .rd_nxt_instr                      (rd_nxt_instr                     ),
                                      .crc_error_detecter                (crc_error_detecter               ),
                                      .enter_lpbk                        (enter_lpbk                       ),
                                      .sop_detected                      (sop_detected                     ),
                                      .crc_result                        (crc_result                       ),
                                      .crc_data_valid                    (crc_data_valid                   ),  
                                      .crc_data_be                       (crc_data_be                      ),  
                                      .crc_data_eop                      (crc_data_eop                     ),    
                                      .crc_data                          (crc_data_in                      ),
                                      .lpbk_error                        (lpbk_error                       ),
                                      .opcode_error                      (opcode_error                     ),
                                      .idle_count_error                  (idle_count_error                 ),
                                      .eop_error                         (eop_error                        ),
                                      .jtag_1149_d10_mstr_rsp_data       (jtag_1149_d10_mstr_rsp_data      ),
                                      .jtag_1149_d10_mstr_rsp_data_be    (jtag_1149_d10_mstr_rsp_data_be   ),
                                      .jtag_1149_d10_mstr_rsp_data_vld   (jtag_1149_d10_mstr_rsp_data_vld  ),
                                      .jtag_1149_d10_mstr_crc_err_cnt    (jtag_1149_d10_mstr_crc_err_cnt   )
                                     );
  
 
  jtag_1149_d10_mstr_rx_error_detector #(
                                        .DATA_WIDTH (DATA_WIDTH  )
                                       )
              i_mstr_rx_error_detector (
                                       .clk                   (clk                  ),
                                       .rst_n                 (rst_n                ),
                                       .decoded_data          (decoded_data         ),
                                       .decoder_k_out         (decoder_k_out        ),
                                       .error_char_detected   (error_char_detected  )
                                      ); 


  jtag_1149_d10_mstr_rx_flow_ctrl_detector #(
                                           .DATA_WIDTH (DATA_WIDTH  )
                                          )
             i_mstr_rx_flow_ctrl_detector (
                                          .clk             (clk            ),
                                          .rst_n           (rst_n          ),
                                          .decoded_data    (decoded_data   ),
                                          .decoder_k_out   (decoder_k_out  ),
                                          .xoff_detected   (xoff_detected  ),
                                          .xon_detected    (xon_detected   )
                                         );

endmodule

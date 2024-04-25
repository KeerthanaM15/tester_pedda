//////////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.               *////
////*  Author: Prabhu Munisamy                                           *////
////*  Department: CoE                                                   *////
////*  Created on: Thursday 07 Mar 2024 19:55:00 IST                     *////
////*  Project: IEEE1149.10 IP Design                                    *////
////*  Module: jtag_1149_d10_mstr_tx_ctrl                                *////
////*  Description: Tx controller module                                 *////
//////////////////////////////////////////////////////////////////////////////

`include "defines.vh"
module jtag_1149_d10_mstr_tx_ctrl
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
  input                           send_comp_char, //TODO
  input                           send_pkt_vld,
   /* verilator lint_off UNUSEDSIGNAL */
  input [BYTE_WIDTH-1:0]          send_pkt_type, //TODO
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
   /* verilator lint_off UNUSEDSIGNAL */
  input                           ptrn_end,//TODO
  
  input                           enter_lpbk,
  input                           raw_data_vld,
  input [D_WORD_WIDTH-1:0]        raw_data_in,
  input                           exit_lpbk_mode,
  output reg                      pkt_txm_done,
  output reg                      read_next_loc,
  output reg                      comp_char_done,

  input                           rd_nxt_instr,
 // input [BYTE_WIDTH-6 : 0]        instr_type,
  input                           instr_retry,
  input                           suspend_xmission,
  output reg                      start_compare, //loopback //to be level signal to RX ctrl
 // output reg  [CNT_WIDTH-1 : 0]   compare_delay, //loopback
  output reg                      lpbk_data_vld, //loopback
  output reg  [BYTE_WIDTH-1 : 0]  lpbk_src_data, //loopback
  output reg                      raw_lpbk_entered, //loopback to sram ctrl

  input [D_WORD_WIDTH-1:0]        crc_data_out,
  output reg  [D_WORD_WIDTH-1:0]  crc_data_in,
  output reg  [NIBBLE_WIDTH-1:0]  crc_data_be,
  output reg                      crc_data_vld,
  output reg                      crc_data_eop,

  output reg                      scan_pyld_read_en,

  output reg  [BYTE_WIDTH-1:0]    data_enc,
  output reg                      encoder_k_out
  );

  localparam IDLE_STATE           = 0;
  localparam COMPILANCE_STATE     = 1;
  localparam CONFIG_STATE         = 2;
  localparam TARGET_STATE         = 3;
  localparam RESET_STATE          = 4;
  localparam RAW_STATE            = 5;
  localparam CH_SEL_STATE         = 6;
  localparam SCAN_STATE           = 7;
  localparam SCAN_PYLD_STATE      = 8;
  localparam SOP_STATE            = 9;
  //localparam CMD_STATE            = 10;
  localparam EOP_STATE            = 10;
  localparam CRC_STATE            = 11;
  localparam PKT_CHECK_STATE      = 12;
  localparam RAW_MODE_STATE       = 13;

  reg [WORD_WIDTH-1:0]            target_id_reg;
  reg [WORD_WIDTH-1:0]            reset_value_reg;
  reg [WORD_WIDTH-1:0]            raw_value_reg;

  reg [D_WORD_WIDTH-1:0]          crc_data_reg;
  reg                             comp_en;
  reg [NIBBLE_WIDTH-1:0]          counter;
  reg [1:0]                       idle_char_count;
  reg                             idle_char_count_en;
  reg [D_WORD_WIDTH-1:0]          raw_data_reg;
  reg                             raw_mode_en;
  reg [48-1:0]                    ch_sel_pkt_reg;
  reg [80-1:0]                    scan_pkt_reg;
  reg [D_WORD_WIDTH-1:0]          scan_pyld;
  reg                             scan_pyld_rd_entered;
  reg                             scan_pkt_entered;
  reg                             last_scan_data_word_en;
  reg [NIBBLE_WIDTH-1:0]          state;

  always@(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      pkt_txm_done              <= 1'b0;
      crc_data_vld              <= 1'b0;
      crc_data_be               <= 4'h0;
      crc_data_eop              <= 1'b0;
      crc_data_in               <= {32{1'b0}};
      crc_data_reg              <= {32{1'b0}};
      comp_en                   <= 1'b0;
      comp_char_done            <= 1'b0;
      counter                   <= 4'h0;
      encoder_k_out             <= 1'b0;
      data_enc                  <= 8'b00; //TODO
      idle_char_count           <= 2'h0;
      idle_char_count_en        <= 1'b0;
      target_id_reg             <= {16{1'b0}};
      reset_value_reg           <= {16{1'b0}};
      raw_value_reg             <= {16{1'b0}};
      raw_data_reg              <= {32{1'b0}}; //to receive the raw src 32bit data
      raw_mode_en               <= 1'b0; //internal en signal that switches to raw_mode_state
      raw_lpbk_entered          <= 1'b0; //To SRAM ctrl from TX Ctrl
      start_compare             <= 1'b0;
      lpbk_data_vld             <= 1'b0;
      lpbk_src_data             <= 8'h00; //To TX ctrl
      ch_sel_pkt_reg            <= {48{1'b0}};
      scan_pkt_reg              <= {80{1'b0}};
      scan_pyld_read_en         <= 1'b0;
      scan_pyld                 <= {32{1'b0}};
      scan_pyld_rd_entered      <= 1'b0;
      scan_pkt_entered          <= 1'b0;
      last_scan_data_word_en    <= 1'b0;
      state                     <= IDLE_STATE;
    end
    else begin
      case(state)
        IDLE_STATE    : begin
                          encoder_k_out    <= 1'b1;
                          idle_char_count  <= idle_char_count + 2'h1;
                          crc_data_vld     <= 1'b0;
                          crc_data_eop     <= 1'b0;
                          read_next_loc    <= 1'b0;
                          comp_char_done   <= 1'b0;
                          pkt_txm_done     <= 1'b0;
                          if(send_comp_char) begin //send_pkt_vld single pulse
                            if(idle_char_count == 2'b00) begin
                              data_enc           <= `COMPLIANCE_CHAR;
                              comp_en            <= 1'b1;
                              idle_char_count_en <= 1'b0;
                              state              <= COMPILANCE_STATE;
                            end
                            else begin
                              data_enc           <= `IDLE_CHAR;
                              comp_en            <= 1'b1;
                              idle_char_count_en <= 1'b1;
                              state              <= IDLE_STATE;
                            end
                          end
                          else if(send_pkt_vld) begin //send_pkt_vld single pulse
                            if(idle_char_count == 2'b00) begin
                              data_enc           <= `SOP_CHAR;
                              idle_char_count_en <= 1'b0;
                              state              <= SOP_STATE;
                            end
                            else begin
                              data_enc           <= `IDLE_CHAR;
                              idle_char_count_en <= 1'b1;
                              state              <= IDLE_STATE;
                            end
                          end
                          else if(idle_char_count_en) begin
                            if(idle_char_count == 2'b00) begin
                              if(comp_en) begin
                                data_enc           <= `COMPLIANCE_CHAR;
                                idle_char_count_en <= 1'b0;
                                state              <= COMPILANCE_STATE;
                              end
                              else begin
                                data_enc           <= `SOP_CHAR;
                                idle_char_count_en <= 1'b0;
                                state              <= SOP_STATE;
                              end
                            end
                            else begin
                              data_enc           <= `IDLE_CHAR;
                              state              <= IDLE_STATE;
                            end
                          end
                          else begin
                            data_enc       <= `IDLE_CHAR;
                            state          <= IDLE_STATE;
                          end
                        end
  COMPILANCE_STATE    : begin
                          idle_char_count  <= 2'h0;
                          comp_en          <= 1'b0;
                          if(counter < 4'h6) begin
                            counter        <= counter + 1'b1;
                            encoder_k_out  <= 1'b1;
                            data_enc       <= `COMPLIANCE_CHAR;
                            state          <= COMPILANCE_STATE;
                          end
                          else begin
                            counter        <= 4'h0;
                            encoder_k_out  <= 1'b1;
                            comp_char_done <= 1'b1;
                            data_enc       <= `COMPLIANCE_CHAR;
                            state          <= IDLE_STATE;
                          end
                        end
   PKT_CHECK_STATE    : begin
                          encoder_k_out       <= 1'b1;
                          crc_data_vld        <= 1'b0;
                          crc_data_eop        <= 1'b0;
                          pkt_txm_done        <= 1'b0;
                          idle_char_count     <= idle_char_count + 2'h1;
                          if(suspend_xmission) begin
                            data_enc          <= `IDLE_CHAR;
                            state             <= PKT_CHECK_STATE;
                          end
                          else if(rd_nxt_instr) begin
                            read_next_loc     <= 1'b1;
                            state             <= IDLE_STATE;
                          end
                          else if(scan_pkt_entered) begin
                            data_enc          <= `IDLE_CHAR;
                            read_next_loc     <= 1'b1;
                            scan_pkt_entered  <= 1'b0;
                            state             <= IDLE_STATE;
                          end
                          else if(instr_retry) begin
                            if(idle_char_count == 2'b00) begin
                              data_enc           <= `SOP_CHAR;
                              idle_char_count_en <= 1'b0;
                              state              <= SOP_STATE;
                            end
                            else begin
                              data_enc           <= `IDLE_CHAR;
                              idle_char_count_en <= 1'b1;
                              state              <= PKT_CHECK_STATE;
                            end
                          end
                          else if(idle_char_count_en) begin
                            if(idle_char_count == 2'b00) begin
                              data_enc           <= `SOP_CHAR;
                              idle_char_count_en <= 1'b0;
                              state              <= SOP_STATE;
                            end
                            else begin
                              data_enc           <= `IDLE_CHAR;
                              state              <= PKT_CHECK_STATE;
                            end
                          end
                          else begin
                            data_enc       <= `IDLE_CHAR;
                            state          <= PKT_CHECK_STATE;
                          end
                        end
         SOP_STATE    : begin
                          idle_char_count  <= 2'h0;
                          encoder_k_out    <= 1'b0;
                          crc_data_be      <= 4'b1111;
                          crc_data_vld     <= 1'b1;
                          if(send_pkt_type[2:0] == 3'b001) begin
                            data_enc       <= `INBD_CFG_CMD;
                            crc_data_in    <= {8'h00,`INBD_CFG_CMD,send_target_id[7:0],send_target_id[15:8]};//TODO need to check byte order
                            target_id_reg  <= send_target_id;//TODO need to check byte order
                            state          <= CONFIG_STATE;
                          end
                          else if(send_pkt_type[2:0] == 3'b010) begin
                            data_enc       <= `INBD_TGT_CMD;
                            crc_data_in    <= {8'h00,`INBD_TGT_CMD,send_target_id[7:0],send_target_id[15:8]};//TODO need to check byte order
                            target_id_reg  <= send_target_id;//TODO need to check byte order
                            state          <= TARGET_STATE;
                          end
                          else if(send_pkt_type[2:0] == 3'b011) begin
                            data_enc       <= `INBD_RST_CMD;
                            crc_data_in    <= {8'h00,`INBD_RST_CMD,send_reset_value[7:0],send_reset_value[15:8]};//TODO need to check byte order
                            reset_value_reg <= send_reset_value;
                            state          <= RESET_STATE;
                          end
                          else if(send_pkt_type[2:0] == 3'b100) begin
                            data_enc       <= `INBD_RAW_CMD;
                            crc_data_in    <= {8'h00,`INBD_RAW_CMD,send_raw_value[7:0],send_raw_value[15:8]};//TODO need to check byte order
                            raw_value_reg  <= send_raw_value;
                            state          <= RAW_STATE;
                          end
                          else if(send_pkt_type[2:0] == 3'b101) begin
                            data_enc       <= `INBD_CHSEL_CMD;
                            crc_data_in    <= {`INBD_CHSEL_CMD,`SCAN_GROUP,8'h01}; //`CH_SELECT[15:8]};//TODO need to check byte order
                            ch_sel_pkt_reg <= {`SCAN_GROUP,`CH_SELECT,send_ch_sel,8'h00}; //48bits
                            state          <= CH_SEL_STATE;
                          end
                          else if(send_pkt_type[2:0] == 3'b110) begin
                            data_enc       <= `INBD_SCAN_CMD;
                            crc_data_in    <= {`INBD_SCAN_CMD,scan_pkt_id,4'h0,scan_pkt_icsu,4'h0,scan_pkt_payld_frame};//TODO need to check byte order
                            scan_pkt_reg   <= {scan_pkt_id,4'h0,scan_pkt_icsu,4'h0,scan_pkt_payld_frame,24'h0000_00,scan_pkt_cycle_count,24'h0000_00}; //80bits
                            state          <= SCAN_STATE;
                          end
                          else begin
                            state          <= IDLE_STATE; //TODO
                          end
                        end
      CONFIG_STATE    : begin
                          target_id_reg  <= {target_id_reg[7:0],target_id_reg[15:8]};//TODO need to check byte order
                          data_enc       <= target_id_reg[7:0];//TODO need to check byte order
                          crc_data_vld   <= 1'b0;
                          crc_data_reg   <= crc_data_out;
                          if(counter < 4'h1) begin
                            counter <= counter + 1'b1;
                            state   <= CONFIG_STATE;
                          end
                          else begin
                            counter <= 4'h0;
                            state   <= CRC_STATE;
                          end
                        end
      TARGET_STATE    : begin
                          target_id_reg  <= {target_id_reg[7:0],target_id_reg[15:8]};//TODO need to check byte order
                          data_enc       <= target_id_reg[7:0];//TODO need to check byte order
                          crc_data_vld   <= 1'b0;
                          crc_data_reg   <= crc_data_out;
                          if(counter < 4'h1) begin
                            counter <= counter + 1'b1;
                            state   <= TARGET_STATE;
                          end
                          else begin
                            counter <= 4'h0;
                            state   <= CRC_STATE;
                          end
                        end
       RESET_STATE    : begin
                          reset_value_reg  <= {reset_value_reg[7:0],reset_value_reg[15:8]};//TODO need to check byte order
                          data_enc       <= reset_value_reg[7:0];//TODO need to check byte order
                          crc_data_vld   <= 1'b0;
                          crc_data_reg   <= crc_data_out;
                          if(counter < 4'h1) begin
                            counter <= counter + 1'b1;
                            state   <= RESET_STATE;
                          end
                          else begin
                            counter <= 4'h0;
                            state   <= CRC_STATE;
                          end
                        end
         RAW_STATE    : begin
                          raw_mode_en    <= 1'b1; //indicates RAW mode entered
                          raw_value_reg  <= {raw_value_reg[7:0],raw_value_reg[15:8]};//TODO need to check byte order
                          data_enc       <= raw_value_reg[7:0];//TODO need to check byte order
                          crc_data_vld   <= 1'b0;
                          crc_data_reg   <= crc_data_out;
                          if(counter < 4'h1) begin
                            counter <= counter + 1'b1;
                            state   <= RAW_STATE;
                          end
                          else begin
                            counter <= 4'h0;
                            state   <= CRC_STATE;
                          end
                        end
      CH_SEL_STATE    : begin
                          data_enc       <= ch_sel_pkt_reg[47:40];
                          ch_sel_pkt_reg <= {ch_sel_pkt_reg[39:0],ch_sel_pkt_reg[47:40]};
                          if(counter < 4'h5) begin
                            if(counter == 4'h0) begin
                              //crc_data_in  <= {`CH_SELECT[7:0],send_ch_sel,8'h00,8'h00};
                              crc_data_in  <= {8'h00,send_ch_sel,8'h00,8'h00};
                              crc_data_be  <= 4'b1110;
                              crc_data_vld <= 1'b1;
                            end
                            else begin
                              crc_data_vld <= 1'b0;
                            end
                            counter <= counter + 1'b1;
                            state   <= CH_SEL_STATE;
                          end
                          else begin
                            crc_data_reg   <= crc_data_out;
                            counter        <= 4'h0;
                            state          <= CRC_STATE;
                          end
                        end
        SCAN_STATE    : begin
                          data_enc     <= scan_pkt_reg[79:72];
                          scan_pkt_reg <= {scan_pkt_reg[71:0],scan_pkt_reg[79:72]};
                          if(counter < 4'h9) begin
                            if(counter == 4'h0) begin
                              scan_pyld_read_en <= 1'b0;
                              crc_data_in       <= {24'h0000_00,scan_pkt_cycle_count};
                              crc_data_be       <= 4'b1111;
                              crc_data_vld      <= 1'b1;
                            end
                            else if(counter == 4'h1) begin
                              crc_data_in       <= {24'h0000_00,8'h00};
                              crc_data_be       <= 4'b1110;
                              crc_data_vld      <= 1'b1;
                            end
                            else begin
                              crc_data_vld <= 1'b0;
                              if(counter == 4'h4) begin //latency depends on read time of SRAM Ctrl
                                scan_pyld_read_en <= 1'b1; //indicates SRAM ctrl to start read for scan payload
                              end
                              else begin
                                scan_pyld_read_en <= 1'b0; //indicates SRAM ctrl to start read for scan payload
                              end
                            end
                            counter <= counter + 1'b1;
                            state   <= SCAN_STATE;
                          end
                          else begin
                           //crc_data_reg   <= crc_data_out;
                            //scan_pyld_read_en <= 1'b1; //indicates SRAM ctrl to start read for scan payload
                            counter           <= 4'h0;
                            state             <= SCAN_PYLD_STATE;
                          end
                        end
   SCAN_PYLD_STATE    : begin
                          scan_pyld_read_en <= 1'b0;
                          scan_pkt_entered  <= 1'b1;
                          if((test_ptrn_data_vld) && (!test_ptrn_data_last)) begin //assuming vld asserts for every 4 cycle once
                            //scan_pyld              <= {test_ptrn_data[23:0],test_ptrn_data[31:24]};
                            //crc_data_in            <= test_ptrn_data;
                            //data_enc               <= test_ptrn_data[31:24];
                            scan_pyld              <= {test_ptrn_data[7:0],test_ptrn_data[31:8]};
                            crc_data_in            <= {test_ptrn_data[7:0],test_ptrn_data[15:8],test_ptrn_data[23:16],test_ptrn_data[31:24]};
                            data_enc               <= test_ptrn_data[7:0];
                            scan_pyld_rd_entered   <= 1'b1; //to indicate counting scan pyld in multiples of four
                            last_scan_data_word_en <= 1'b0;
                            crc_data_be            <= 4'b1111;
                            crc_data_vld           <= 1'b1;
                            state                  <= SCAN_PYLD_STATE;
                          end
                          else if((test_ptrn_data_vld) && (test_ptrn_data_last)) begin
                            scan_pyld              <= {test_ptrn_data[7:0],test_ptrn_data[31:8]};
                            crc_data_in            <= {test_ptrn_data[7:0],test_ptrn_data[15:8],test_ptrn_data[23:16],test_ptrn_data[31:24]};
                            data_enc               <= test_ptrn_data[7:0];
                            last_scan_data_word_en <= 1'b1;
                            crc_data_be            <= 4'b1111;
                            crc_data_vld           <= 1'b1;
                            state                  <= SCAN_PYLD_STATE;
                          end
                          else begin
                            crc_data_vld           <= 1'b0;
                            if(scan_pyld_rd_entered) begin
                              data_enc             <= scan_pyld[7:0];
                              if(counter < 4'h2) begin
                                scan_pyld          <= {scan_pyld[7:0],scan_pyld[31:8]};
                                counter            <= counter + 1'b1;
                                state              <= SCAN_PYLD_STATE;
                              end
                              else begin
                                counter            <= 4'h0;
                                if(last_scan_data_word_en) begin
                                  crc_data_reg     <= crc_data_out;
                                  state            <= CRC_STATE;
                                end
                                else begin
                                  state            <= SCAN_PYLD_STATE;
                                end
                              end
                            end
                            else begin
                              state                <= SCAN_PYLD_STATE;
                            end
                          end
                        end
         CRC_STATE    : begin
                          crc_data_reg    <= {crc_data_reg[7:0],crc_data_reg[31:8]};
                          data_enc        <= crc_data_reg[7:0];
                          crc_data_vld    <= 1'b0;
                          if(counter < 4'h3) begin
                            counter       <= counter + 1'b1;
                            state         <= CRC_STATE;
                          end
                          else begin
                            counter       <= 4'h0;
                            state         <= EOP_STATE;
                          end
                        end
         EOP_STATE    : begin
                          encoder_k_out   <= 1'b1;
                          data_enc        <= `EOP_CHAR;
                          crc_data_in     <= 32'h0000_0000;
                          crc_data_be     <= 4'b1111;
                          crc_data_vld    <= 1'b0;
                          crc_data_eop    <= 1'b1;
                          if(counter < 4'h3) begin
                            counter       <= counter + 1'b1;
                            state         <= EOP_STATE;
                          end
                          else begin
                            counter       <= 4'h0;
                            pkt_txm_done  <= 1'b1;
                            if(raw_mode_en) begin
                              raw_mode_en <= 1'b0;
                              state       <= RAW_MODE_STATE;
                            end
                            else begin
                              state       <= PKT_CHECK_STATE;
                            end
                          end
                        end
    RAW_MODE_STATE    : begin
                          pkt_txm_done       <= 1'b0;
                          if(exit_lpbk_mode) begin
                            encoder_k_out    <= 1'b1;
                            idle_char_count  <= 2'h1; //To compensate idle in x4 here idle count value set to one
                            data_enc         <= `IDLE_CHAR; 
                            lpbk_data_vld    <= 1'b0;
                            start_compare    <= 1'b0;
                            raw_lpbk_entered <= 1'b0;
                            counter          <= 4'h0;
                            state            <= IDLE_STATE; //TODO IDLE_STATE or PKT_CHECK_STATE
                          end
                          else if(enter_lpbk) begin
                            raw_lpbk_entered <= 1'b1;
                            if(raw_data_vld) begin
                              //raw_data_reg   <= {raw_data_in[23:0],raw_data_in[31:24]}; //32bits
                              //data_enc       <= raw_data_in[31:24];
                              raw_data_reg   <= {raw_data_in[7:0],raw_data_in[31:8]}; //32bits
                              data_enc       <= raw_data_in[7:0];
                              encoder_k_out  <= 1'b0; //TODO maybe varies b/w 1 and 0
                              start_compare  <= 1'b1;
                              lpbk_data_vld  <= 1'b1; //indicates valid raw data to tx ctrl
                              lpbk_src_data  <= raw_data_in[7:0];
                              counter        <= 4'h0;
                              state          <= RAW_MODE_STATE;
                            end
                            else if((counter < 4'h3) && (lpbk_data_vld)) begin
                              raw_data_reg   <= {raw_data_reg[7:0],raw_data_reg[31:8]}; //32bits
                              encoder_k_out  <= 1'b0; //TODO maybe varies b/w 1 and 0
                              data_enc       <= raw_data_reg[7:0];
                              lpbk_data_vld  <= 1'b1;
                              lpbk_src_data  <= raw_data_reg[7:0];
                              counter        <= counter + 1'b1;
                              state          <= RAW_MODE_STATE;
                            end
                            else begin
                              encoder_k_out  <= 1'b1;
                              data_enc       <= `IDLE_CHAR;
                              start_compare  <= 1'b0;
                              lpbk_data_vld  <= 1'b0;
                              state          <= RAW_MODE_STATE;
                            end
                          end
                          else begin
                            encoder_k_out    <= 1'b1;
                            data_enc         <= `IDLE_CHAR;
                            start_compare    <= 1'b0;
                            raw_lpbk_entered <= 1'b0;
                            state            <= RAW_MODE_STATE;
                          end
                        end
              default : begin
                          encoder_k_out      <= 1'b1;
                          data_enc           <= `IDLE_CHAR;
                          state              <= IDLE_STATE;
                        end
      endcase
    end
  end

endmodule


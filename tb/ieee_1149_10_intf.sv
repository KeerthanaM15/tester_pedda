interface ieee_1149_10_intf(input logic ieee_1149_10_clk, reset);
  logic[7:0] ieee_1149_10_parallel_in;
logic[7:0] ieee_1149_10_parallel_out;
logic tb_k_in;
logic raw_mode;
logic disable_raw_mode;
logic invalid_packet_sent;
logic wrong_packet_sent;
logic wrong_crc_sent;
logic junk_data_sent;
logic x_data_sent;
logic packet_with_delay_sent;
logic config_packet_sent;
logic [15:0] temp_target_id;
logic se;
logic [15:0] target_id;
logic [4:0]state;
logic config_packet_entered;
logic target_packet_entered;
logic reset_packet_count;
logic raw_mode_entered;
logic scan_packet_entered;
logic scan_shift_start;
logic load_piso;
logic trgtpkt_wrong_crc_sent;
logic reset10_check;
logic trst10_check; 
logic pedda_status_response;
logic pedda_status_response_check;
logic response_pkt_cmd_check;

  logic [95:0]temp_pkt_drive;
  logic [31:0]sram_rd_data;
  logic [9:0]sram_addr;
  logic [95:0]temp_config_pkt;
  logic [95:0]temp_target_pkt;
  logic [95:0]temp_reset_pkt;
  logic [95:0]temp_raw_pkt;
  logic [127:0]temp_ch_sel_pkt;
  logic [223:0]temp_scan_64_pkt;
  logic [287:0]temp_scan_128_pkt;
  
  logic [95:0]resp_config_data;
  logic [95:0]resp_target_data;
  logic [95:0]resp_reset_data;
  logic [95:0]resp_raw_data;
  logic [127:0]resp_ch_sel_data;
  logic [159+64:0]resp_scan_64_data;
  logic [159+128:0]resp_scan_128_data;
  logic [7:0]cmd;
  logic [31:0]size;
  logic error_id;
  logic [2:0]pedda_mst_status1_out;
  
  property opcode_err_check_config;
    @(posedge ieee_1149_10_clk) disable iff((!reset))
    if(tb_k_in==0)
      (ieee_1149_10_parallel_in != 8'h81) ##1 (pedda_mst_status1_out == 3'd1);
  endproperty
  
  OPCODE_ERROR_CHECK:assert property(opcode_err_check_config)
    $display($time," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~OPCODE ERROR CHECK PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    else
      $display($time, " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~OPCODE ERROR CHECK FAIL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    
    property eop_err_check_config;
    @(posedge ieee_1149_10_clk) disable iff((!reset))
      (ieee_1149_10_parallel_in=='hfd) |->
      (resp_config_data[31:0] != 32'hfdfdfdfd) ##[1:5] (pedda_mst_status1_out == 3'd3);
  endproperty
  
    EOP_ERROR_CHECK:assert property(eop_err_check_config)
    $display($time," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EOP ERROR CHECK PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    else
      $display($time, " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EOP ERROR CHECK FAIL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

	property eop_err_spcl_data_check_config;
    @(posedge ieee_1149_10_clk) disable iff((!reset))
      (ieee_1149_10_parallel_in=='hfd) |->
      (resp_config_data[31:0] != 32'hfdfdfdfd) ##[1:5] (pedda_mst_status1_out == 3'd2);
  endproperty
  
    EOP_ERROR_SPCL_DATA_CHECK:assert property(eop_err_spcl_data_check_config)
    $display($time," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EOP ERROR WITH SPCL CHARACTER IN EOP CHECK PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    else
      $display($time, " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~EOP ERROR WITH SPCL CHARACTER IN EOP CHECK FAIL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

	property idle_char_count_check_config;
    @(posedge ieee_1149_10_clk) disable iff((!reset)) 
      (ieee_1149_10_parallel_out=='hbc) |-> ##[1:$] (pedda_mst_status1_out == 3'd7);
  endproperty
  
   IDLE_CHAR_COUNT_CHECK:assert property(idle_char_count_check_config)
    $display($time," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDLE CHAR COUNT CHECK PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    else
      $display($time, " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~IDLE CHAR COUNT CHECK FAIL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");

property scan_rsp_timeout_check_config;
    @(posedge ieee_1149_10_clk) 
      (ieee_1149_10_parallel_out=='hfd) |-> ##[1000:$] (pedda_mst_status1_out == 3'd6);
  endproperty
  
   SCAN_RSP_TIMEOUT_CHECK:assert property(scan_rsp_timeout_check_config)
    $display($time," ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SCAN RSP TIMEOUT CHECK PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    else
      $display($time, " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~SCAN RSP TIMEOUT CHECK FAIL~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");


  

endinterface:ieee_1149_10_intf


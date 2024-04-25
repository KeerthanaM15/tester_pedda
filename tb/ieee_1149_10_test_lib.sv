class ieee_1149_10_base_test extends uvm_test;

  `uvm_component_utils(ieee_1149_10_base_test)

	 gen_env1 	env1 ;
	 config_test_v_sequence 	con_vseq;
  target_test_v_sequence tar_vseq;
  reset_test_v_sequence res_vseq;
  targetpkt_after_resetpkt_test_v_sequence targetpkt_after_resetpkt_vseq;
  raw_test_v_sequence raw_vseq;
  ch_select_test_v_sequence ch_sel_vseq;
  targetpkt_without_configpkt_test_v_sequence targetpkt_without_configpkt_vseq;
  scan_64_test_v_sequence scan_64_vseq;
  scan_128_test_v_sequence scan_128_vseq;
  back2back_target_test_v_sequence b2b_tar_vseq;
  trs_reset_test_v_sequence trs_res_vseq;
  res_reset_test_v_sequence res_res_vseq;
  unconfigured_scan_test_v_sequence unconfig_scan_vseq;
  opcode_error_check_test_v_sequence op_err_vseq;
  idle_count_error_check_test_v_sequence idle_cnt_err_vseq;
  eop_error_check_test_v_sequence eop_err_vseq;
  eop_error_spcl_data_check_test_v_sequence eop_err_spcl_data_vseq;
  target_id0_test_v_sequence tar_id0_vseq;
 wrong_configpkt_format_test_v_sequence wrong_frmt_vseq;
wrong_crc_test_v_sequence wrong_crc_vseq;
config_after_raw_test_v_sequence config_aftr_raw_vseq;
target_after_raw_test_v_sequence target_aftr_raw_vseq;
wrong_resp_test_v_sequence wrong_resp_vseq;
scan_rsp_timeout_check_test_v_sequence scan_rsp_timeout_vseq;

	virtual ieee_1149_10_intf inf;

  function new (string name="ieee_1149_10_base_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
	env1 = gen_env1::type_id::create("env1",this);
    con_vseq=config_test_v_sequence::type_id::create("con_vseq",this);
    tar_vseq=target_test_v_sequence::type_id::create("tar_vseq",this);
    res_vseq=reset_test_v_sequence::type_id::create("res_vseq",this);
    targetpkt_after_resetpkt_vseq=targetpkt_after_resetpkt_test_v_sequence::type_id::create("targetpkt_after_resetpkt_vseq",this);
    raw_vseq=raw_test_v_sequence::type_id::create("raw_vseq",this);
    ch_sel_vseq=ch_select_test_v_sequence::type_id::create("ch_sel_vseq",this);
    targetpkt_without_configpkt_vseq=targetpkt_without_configpkt_test_v_sequence::type_id::create("targetpkt_without_configpkt_vseq",this);
    scan_64_vseq=scan_64_test_v_sequence::type_id::create("scan_64_seq",this);
scan_128_vseq=scan_128_test_v_sequence::type_id::create("scan_128_seq",this);
    b2b_tar_vseq=back2back_target_test_v_sequence::type_id::create("b2b_tar_vseq",this);
    trs_res_vseq=trs_reset_test_v_sequence::type_id::create("trs_res_vseq",this);
    res_res_vseq=res_reset_test_v_sequence::type_id::create("res_res_vseq",this);
    unconfig_scan_vseq=unconfigured_scan_test_v_sequence::type_id::create("unconfig_scan_vseq",this);
    op_err_vseq=opcode_error_check_test_v_sequence::type_id::create("op_err_vseq",this);
    idle_cnt_err_vseq=idle_count_error_check_test_v_sequence::type_id::create("idle_cnt_err_vseq",this);
    eop_err_vseq=eop_error_check_test_v_sequence::type_id::create("eop_err_vseq",this);
    eop_err_spcl_data_vseq=eop_error_spcl_data_check_test_v_sequence::type_id::create("eop_err_spcl_data_vseq",this);
    tar_id0_vseq=target_id0_test_v_sequence::type_id::create("tar_id0_vseq",this);
    wrong_frmt_vseq=wrong_configpkt_format_test_v_sequence::type_id::create("wrong_frmt_vseq",this);
    wrong_crc_vseq=wrong_crc_test_v_sequence::type_id::create("wrong_crc_vseq",this);
    config_aftr_raw_vseq=config_after_raw_test_v_sequence::type_id::create("config_aftr_raw_vseq",this);
    target_aftr_raw_vseq=target_after_raw_test_v_sequence::type_id::create("target_aftr_raw_vseq",this);
    wrong_resp_vseq=wrong_resp_test_v_sequence::type_id::create("wrong_resp_vseq",this);
    scan_rsp_timeout_vseq=scan_rsp_timeout_check_test_v_sequence::type_id::create("scan_rsp_timeout_vseq",this);
    uvm_config_db#(virtual ieee_1149_10_intf)::set(null,"uvm_test_top","ieee_1149_10_intf",inf);
  endfunction
  
endclass

class ieee_1149_10_config_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_config_test)

  function new (string name="ieee_1149_10_config_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      con_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_target_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_target_test)

  function new (string name="ieee_1149_10_target_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      tar_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_target_id0_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_target_id0_test)

  function new (string name="ieee_1149_10_target_id0_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      tar_id0_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass


class ieee_1149_10_reset_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_reset_test)

  function new (string name="ieee_1149_10_reset_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      res_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_targetpkt_after_resetpkt_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_targetpkt_after_resetpkt_test)

  function new (string name="ieee_1149_10_targetpkt_after_resetpkt_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      targetpkt_after_resetpkt_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_wrong_configpkt_format_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_wrong_configpkt_format_test)

  function new (string name="ieee_1149_10_wrong_configpkt_format_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      wrong_frmt_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass


class ieee_1149_10_raw_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_raw_test)

  function new (string name="ieee_1149_10_raw_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      raw_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_ch_select_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_ch_select_test)

  function new (string name="ieee_1149_10_ch_select_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      ch_sel_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_targetpkt_without_configpkt_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_targetpkt_without_configpkt_test)

  function new (string name="ieee_1149_10_targetpkt_without_configpkt_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      targetpkt_without_configpkt_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass


class ieee_1149_10_scan_64_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_scan_64_test)

  function new (string name="ieee_1149_10_scan_64_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      scan_64_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_scan_128_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_scan_128_test)

  function new (string name="ieee_1149_10_scan_128_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);                                                          
      $assertoff();
    scan_128_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_back2back_target_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_back2back_target_test)

  function new (string name="ieee_1149_10_back2back_target_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
    b2b_tar_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_trs_reset_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_trs_reset_test)

  function new (string name="ieee_1149_10_trs_reset_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      trs_res_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_res_reset_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_res_reset_test)

  function new (string name="ieee_1149_10_res_reset_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      res_res_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_unconfigured_scan_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_unconfigured_scan_test)

  function new (string name="ieee_1149_10_unconfigured_scan_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      unconfig_scan_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_opcode_error_check_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_opcode_error_check_test)

  function new (string name="ieee_1149_10_opcode_error_check_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	//need to make changes in the driver
  // need to change the cmd part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      op_err_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_eop_error_check_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_eop_error_check_test)

  function new (string name="ieee_1149_10_eop_error_check_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	//need to make changes in the driver
  // need to change the cmd part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      eop_err_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_eop_error_spcl_data_check_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_eop_error_spcl_data_check_test)

  function new (string name="ieee_1149_10_eop_error_spcl_data_check_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	//need to make changes in the driver
  // need to change the cmd part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      eop_err_spcl_data_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass


class ieee_1149_10_wrong_crc_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_wrong_crc_test)

  function new (string name="ieee_1149_10_wrong_crc_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new
	//need to make changes in the driver
  // need to change the crc part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      wrong_crc_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_config_after_raw_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_config_after_raw_test)

  function new (string name="ieee_1149_10_config_after_raw_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      config_aftr_raw_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_target_after_raw_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_target_after_raw_test)

  function new (string name="ieee_1149_10_target_after_raw_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      target_aftr_raw_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_wrong_resp_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_wrong_resp_test)

  function new (string name="ieee_1149_10_wrong_resp_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      $assertoff();
      wrong_resp_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_idle_count_error_check_test extends ieee_1149_10_base_test;
  
  `uvm_component_utils(ieee_1149_10_idle_count_error_check_test)

  function new (string name="ieee_1149_10_idle_error_check_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	//need to make changes in the driver
  // need to change the cmd part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      idle_cnt_err_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass

class ieee_1149_10_scan_rsp_timeout_check_test extends ieee_1149_10_base_test;  
  `uvm_component_utils(ieee_1149_10_scan_rsp_timeout_check_test)

  function new (string name="ieee_1149_10_scan_rsp_timeout_check_test", uvm_component parent);
    		super.new(name, parent);
  	endfunction : new

	//need to make changes in the driver
  // need to change the cmd part to some other value
  virtual task run_phase(uvm_phase phase);
    begin
      phase.raise_objection(this);
      scan_rsp_timeout_vseq.start(env1.v_sqncr);
      phase.drop_objection(this);
    end
  endtask
  
endclass



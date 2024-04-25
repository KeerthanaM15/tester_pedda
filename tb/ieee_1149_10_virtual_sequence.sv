class ieee_1149_10_virtual_sequence#(int pld_size=64) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
  
  `uvm_object_utils(ieee_1149_10_virtual_sequence)
  `uvm_declare_p_sequencer(ieee_1149_10_virtual_sequencer)
  virtual ieee_1149_10_intf inf;
  function new (string name = "ieee_1149_10_virtual_sequence");
    super.new(name);
  endfunction
  
  ieee_1149_10_sequencer sqncr;
  
  config_seq con_seq;
  target_seq tar_seq;
  reset_seq res_seq;
  raw_sequence raw_seq;
  ch_select1_seq ch_sel_seq;
   indpt_target_seq 	i_tar_seq;
  scan_sequence1 scan_64_seq;
  scan_sequence2 scan_128_seq;
  wrong_crc_sequence wrong_crc_seq;
  wrong_format_sequence wrong_format_seq;
  opcode_error_sequence opcode_error_seq;
  eop_error_sequence eop_error_seq;
  eop_error_spcl_data_sequence eop_error_spcl_data_seq;
  
  task pre_body();
    if(!uvm_config_db#(virtual ieee_1149_10_intf)::get(null," ","ieee_1149_10_intf",inf))
		`uvm_fatal("no_vif",{"virtual interface must be set for :",get_full_name(),"inf"});
    con_seq = config_seq::type_id::create("con_seq");
    tar_seq = target_seq::type_id::create("tar_seq");
    res_seq = reset_seq::type_id::create("res_seq");
    raw_seq = raw_sequence::type_id::create("raw_seq");
    ch_sel_seq = ch_select1_seq::type_id::create("ch_sel_seq");
    i_tar_seq=indpt_target_seq::type_id::create("i_tar_seq");
    scan_64_seq = scan_sequence1::type_id::create("scan_seq");
     scan_128_seq = scan_sequence2::type_id::create("scan_seq");
    wrong_crc_seq = wrong_crc_sequence::type_id::create("wrong_crc_seq");
    wrong_format_seq = wrong_format_sequence::type_id::create("wrong_format_seq");
    opcode_error_seq=opcode_error_sequence::type_id::create("opcode_error_seq");
    eop_error_seq=eop_error_sequence::type_id::create("eop_error_seq");
    eop_error_spcl_data_seq=eop_error_spcl_data_sequence::type_id::create("eop_error_spcl_data_error_seq");
  endtask
  
endclass

class config_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(config_test_v_sequence)
  
  
  function new(string name = "config_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    repeat(56)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass

class target_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(target_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "target_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    @(posedge inf.ieee_1149_10_clk) begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass

class target_id0_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(target_id0_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "target_id0_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on_with(i_tar_seq,p_sequencer.pedda_sqncr,{temp_target_id==16'h0;})
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    @(posedge inf.ieee_1149_10_clk) begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000000_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


class reset_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(reset_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "reset_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0004;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000100_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass

class targetpkt_after_resetpkt_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(targetpkt_after_resetpkt_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "targetpkt_after_resetpkt_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0004;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000100_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass


class raw_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(raw_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "raw_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_raw();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(raw_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
	inf.sram_rd_data = 32'b00000000_00000000_00000000_00000111;
repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_raw();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000000_00000100;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_raw_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            $display("************the received value from master = %h***********",inf.temp_raw_pkt);
          end
      
    end
  endtask
endclass



class ch_select_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(ch_select_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "ch_select_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_ch_sel();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(ch_sel_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_ch_sel();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000101;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=15;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_ch_sel_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass


class targetpkt_without_configpkt_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(targetpkt_without_configpkt_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "targetpkt_without_configpkt_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on_with(i_tar_seq,p_sequencer.pedda_sqncr,{temp_target_id=='h1;})
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
  endtask
  
  task sram_read_task_target();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      repeat(8)@(posedge inf.ieee_1149_10_clk);
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            $display("the received value from master = %h",inf.temp_target_pkt);
          end
      
    end
  endtask
  
endclass


class scan_64_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(scan_64_test_v_sequence)
  int scan_pyld_size;
  bit [9:0]test_addr;
  function new(string name = "scan_64_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_ch_sel();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(ch_sel_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_scan();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(scan_64_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0004;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_ch_sel();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000101;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=15;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_ch_sel_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
          end
      
    end
  endtask
  
  task sram_read_task_scan();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000001_00100010_01000000_00000110;
      scan_pyld_size=(32*inf.sram_rd_data[19:16]);
      test_addr=inf.sram_addr+1;
      fork
        begin
          wait(inf.ieee_1149_10_parallel_out=='hfb);
          for(int i=27;i>=16;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
              //$display("the received value from master = %h",inf.temp_scan_pkt);
            end
        end
        begin
          wait(inf.sram_addr=='h5); 
          inf.sram_rd_data = 32'ha864_b975;
          test_addr=inf.sram_addr+1;
          fork
            begin
              wait(inf.ieee_1149_10_parallel_out=='h75);
              for(int i=15;i>=12;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
            begin
              wait(inf.sram_addr=='h6); 
              inf.sram_rd_data = 32'hfdb9_eca7;
              test_addr=inf.sram_addr+1;
              wait(inf.ieee_1149_10_parallel_out=='ha7);
              for(int i=11;i>=0;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
          join
        end
      join
    end
  endtask
  
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000100_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass


class scan_128_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(scan_128_test_v_sequence)
  int scan_pyld_size;
  bit [9:0]test_addr;
  function new(string name = "scan_128_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_ch_sel();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(ch_sel_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_scan();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(scan_128_seq,p_sequencer.pedda_sqncr)
    repeat(20)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_ch_sel();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000101;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=15;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_ch_sel_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
          end
      
    end
  endtask
  
   task sram_read_task_scan();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000010_00100100_01100010_00000110;
      scan_pyld_size=(32*inf.sram_rd_data[19:16]);
      test_addr=inf.sram_addr+1;
      fork
        begin
          wait(inf.ieee_1149_10_parallel_out=='hfb);
          for(int i=35;i>=24;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.temp_scan_128_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
              //$display("the received value from master = %h",inf.temp_scan_pkt);
            end
        end
        begin
          wait(inf.sram_addr=='h5); 
          inf.sram_rd_data = 32'h9876_5432;
          test_addr=inf.sram_addr+1;
          fork
            begin
              wait(inf.ieee_1149_10_parallel_out=='h32);
              for(int i=23;i>=20;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_128_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
            begin
              wait(inf.sram_addr=='h6); 
              inf.sram_rd_data = 32'hcefa_afde;
              test_addr=inf.sram_addr+1;
              fork
                begin
                  wait(inf.ieee_1149_10_parallel_out=='hde);
                  for(int i=19;i>=16;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_128_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
                end
                begin
                  wait(inf.sram_addr=='h7);
                  inf.sram_rd_data = 32'h0123_4567;
                  test_addr=inf.sram_addr+1;
                  fork
                    begin
                      wait(inf.ieee_1149_10_parallel_out=='h67);
                      for(int i=15;i>=12;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_128_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
                    end
                      
                        begin
                          wait(inf.sram_addr=='h8);
                          inf.sram_rd_data=32'hdefa_dabe;
                          test_addr=inf.sram_addr+1;
                          wait(inf.ieee_1149_10_parallel_out=='hbe);
                          for(int i=11;i>=0;i--)
                            begin
                              @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_128_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                            end
                        end
                  join
                end
              join
            end
          join
        end
      join
    end
    //$display("the value of packet is %h",inf.temp_scan_pkt);
  endtask
    
endclass


class back2back_target_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(back2back_target_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "back2back_target_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_target2();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(i_tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
  task sram_read_task_target2();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000011_00000010;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass

class trs_reset_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(trs_reset_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "trs_reset_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0002;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000010_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass

class res_reset_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(res_reset_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "res_reset_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0001;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass


class unconfigured_scan_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(unconfigured_scan_test_v_sequence)
  int scan_pyld_size;
  bit [9:0]test_addr;
  function new(string name = "unconfigured_scan_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_scan();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(scan_64_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

    
  endtask
  
    
  task sram_read_task_scan();
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);   
      @(posedge inf.ieee_1149_10_clk)
      inf.sram_rd_data = 32'b00000001_00100010_01000000_00000110;
      scan_pyld_size=(32*inf.sram_rd_data[19:16]);
      test_addr=inf.sram_addr+1;
      /*fork
        begin
          wait(inf.ieee_1149_10_parallel_out=='hfb);
          for(int i=27;i>=16;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
              //$display("the received value from master = %h",inf.temp_scan_pkt);
            end
        end
        begin
          wait(inf.sram_addr=='h2); 
          inf.sram_rd_data = 32'ha864_b975;
          test_addr=inf.sram_addr+1;
          fork
            begin
              wait(inf.ieee_1149_10_parallel_out=='h75);
              for(int i=15;i>=12;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
            begin
              wait(inf.sram_addr=='h3); 
              inf.sram_rd_data = 32'hfdb9_eca7;
              test_addr=inf.sram_addr+1;
              wait(inf.ieee_1149_10_parallel_out=='ha7);
              for(int i=11;i>=0;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
          join
        end
      join*/
    end
  endtask
  
endclass

class opcode_error_check_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(opcode_error_check_test_v_sequence)
  
  
  function new(string name = "opcode_error_check_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(opcode_error_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


class eop_error_check_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(eop_error_check_test_v_sequence)
  
  
  function new(string name = "eop_error_check_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(eop_error_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


class eop_error_spcl_data_check_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(eop_error_spcl_data_check_test_v_sequence)
  
  
  function new(string name = "eop_error_spcl_data_check_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(eop_error_spcl_data_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


class wrong_configpkt_format_test_v_sequence extends ieee_1149_10_virtual_sequence;
  //change format while sending response
  `uvm_object_utils(wrong_configpkt_format_test_v_sequence)
  
  
  function new(string name = "wrong_configpkt_format_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(wrong_format_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass

class wrong_crc_test_v_sequence extends ieee_1149_10_virtual_sequence;
  //change format while sending response
  `uvm_object_utils(wrong_crc_test_v_sequence)
  
  
  function new(string name = "wrong_crc_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(24)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(wrong_crc_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


class config_after_raw_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(config_after_raw_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "config_after_raw_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_raw();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(raw_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    inf.sram_rd_data=32'b00000000_00000000_00000000_00000111;
    repeat(36)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd7);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end

    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==10'd2);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_raw();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==10'd3);  
      inf.sram_rd_data = 32'b00000000_00000000_00000000_00000100;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_raw_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            $display("************the received value from master = %h***********",inf.temp_raw_pkt);
          end
      
    end
  endtask
endclass

class target_after_raw_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(target_after_raw_test_v_sequence)
  
  bit [9:0]test_addr;
  function new(string name = "target_after_raw_test_v_sequence");
    super.new(name);
  endfunction
   task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
     `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_raw();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(raw_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    inf.sram_rd_data=32'b00000000_00000000_00000000_00000111;
    repeat(36)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd7);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end

    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_raw();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000000_00000100;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_raw_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            $display("************the received value from master = %h***********",inf.temp_raw_pkt);
          end
      
    end
  endtask
endclass

class wrong_resp_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(wrong_resp_test_v_sequence)
  int scan_pyld_size;
  bit [9:0]test_addr;
  function new(string name = "wrong_resp_test_v_sequence");
    super.new(name);
  endfunction
  task body;
  repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_target();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_ch_sel();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(tar_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    
    sram_read_task_scan();
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on(scan_64_seq,p_sequencer.pedda_sqncr)
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end

    sram_read_task_reset();
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
        inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <= 1;
	end
     
    `uvm_do_on_with(res_seq,p_sequencer.pedda_sqncr,{reset_type=='h0004;})
    repeat(8)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      test_addr=inf.sram_addr;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_target();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000010;
      test_addr=inf.sram_addr+1;
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_target_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  task sram_read_task_ch_sel();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000101;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=15;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_ch_sel_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
          end
      
    end
  endtask
  
  task sram_read_task_scan();
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000001_00100010_01000000_00000110;
      scan_pyld_size=(32*inf.sram_rd_data[19:16]);
      test_addr=inf.sram_addr+1;
      fork
        begin
          wait(inf.ieee_1149_10_parallel_out=='hfb);
          for(int i=27;i>=16;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
              //$display("the received value from master = %h",inf.temp_scan_pkt);
            end
        end
        begin
          wait(inf.sram_addr=='h5); 
          inf.sram_rd_data = 32'ha864_b975;
          test_addr=inf.sram_addr+1;
          fork
            begin
              wait(inf.ieee_1149_10_parallel_out=='h75);
              for(int i=15;i>=12;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
            begin
              wait(inf.sram_addr=='h6); 
              inf.sram_rd_data = 32'hfdb9_eca7;
              test_addr=inf.sram_addr+1;
              wait(inf.ieee_1149_10_parallel_out=='ha7);
              for(int i=11;i>=0;i--)
                begin
                  @(posedge inf.ieee_1149_10_clk);
                  inf.temp_scan_64_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
                  //$display("the received value from master = %h",inf.temp_scan_pkt);
                end
            end
          join
        end
      join
    end
  endtask
  
  task sram_read_task_reset();
    //@(posedge inf.ieee_1149_10_clk) 
    begin
    
      wait(inf.sram_addr==test_addr);  
      inf.sram_rd_data = 32'b00000000_00000000_00000100_00000011;
      test_addr=inf.sram_addr+1;
     wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_reset_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
endclass

class idle_count_error_check_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(idle_count_error_check_test_v_sequence)
  
  
  function new(string name = "idle_count_error_check_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(3)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(5)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    repeat(3)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
   /* wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end*/
      
    end
  endtask
  
endclass


class scan_rsp_timeout_check_test_v_sequence extends ieee_1149_10_virtual_sequence;
  
  `uvm_object_utils(scan_rsp_timeout_check_test_v_sequence)
  
  
  function new(string name = "scan_rsp_timeout_check_test_v_sequence");
    super.new(name);
  endfunction
  
  task body;
    
    repeat(4)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
       
    sram_read_task_config();
    repeat(1040)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
    `uvm_do_on(con_seq,p_sequencer.pedda_sqncr)
    repeat(16)@(posedge inf.ieee_1149_10_clk) begin
	inf.ieee_1149_10_parallel_in <= 'hbc;
	inf.tb_k_in <=1;
	end
  endtask
  
  task sram_read_task_config();
    @(posedge inf.ieee_1149_10_clk) begin
      inf.sram_rd_data = 32'b 00000000_00000000_00000000_00001000;
    
    wait(inf.sram_addr==10'd1);  
      inf.sram_rd_data = 32'b00000000_00000000_00000001_00000001;
      
      wait(inf.ieee_1149_10_parallel_out=='hfb);
      for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.temp_config_pkt[8*i+:8] = inf.ieee_1149_10_parallel_out;
            //$display("the received value from master = %h",inf.temp_pkt);
          end
      
    end
  endtask
  
endclass


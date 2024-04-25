class ieee_1149_10_config_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet config_seq;
 logic[15:0] temp_cfg_target_id;

`uvm_object_param_utils(ieee_1149_10_config_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_config_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_crc==0;req.wrong_format==0;req.wrong_cmd==0;req.wrong_eop==0;req.spcl_eop==0;})
     uvm_config_db#(logic[15:0])::set(null,"*","temp_cfg_target_id",req.cfg_target_id);

  endtask

endclass:ieee_1149_10_config_sequence

class ieee_1149_10_target_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
 // ieee_1149_10_packet#(pld_size)  target_seq;

 logic[15:0] temp_trg_target_id;
//rand logic [15:0]temp_trg_target_id;


`uvm_object_param_utils(ieee_1149_10_target_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_target_sequence");
    super.new(name);
  endfunction
  

  virtual task body();

     	 uvm_config_db#(logic[15:0])::get(null,get_full_name(),"temp_cfg_target_id",temp_trg_target_id);
//	`uvm_do_with(req,{req.cmd=='h42;req.trg_target_id==temp_trg_target_id;})
    `uvm_do_with(req,{req.cmd=='h82;req.trg_target_id==temp_trg_target_id;})
  endtask

endclass:ieee_1149_10_target_sequence


class ieee_1149_10_independent_target_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
  rand bit [15:0]temp_target_id;
  `uvm_object_param_utils(ieee_1149_10_independent_target_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_target_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~the target id value is %b~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",temp_target_id);
    `uvm_do_with(req,{req.cmd=='h82;req.trg_target_id==temp_target_id;})
  endtask

endclass:ieee_1149_10_independent_target_sequence

//*************reset packet to reset the target id to all zeroes************
class ieee_1149_10_reset_sequence#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet target_seq;
  rand bit [15:0]reset_type;

`uvm_object_param_utils(ieee_1149_10_reset_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_reset_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h83;req.packet_type==reset_type;})


  endtask

endclass:ieee_1149_10_reset_sequence

//***********reset packet using type as reset10*********
class ieee_1149_10_res_reset_sequence#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));//Reset10
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_res_reset_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_res_reset_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h03;req.packet_type=='h0001;})
  endtask
endclass:ieee_1149_10_res_reset_sequence

//**********reset packet using type as trst10***********
class ieee_1149_10_trs_reset_sequence#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));//Trst10
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_trs_reset_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_trs_reset_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h03;req.packet_type=='h0002;})


  endtask

endclass:ieee_1149_10_trs_reset_sequence

class ieee_1149_10_raw_sequence#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_raw_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_raw_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h84;req.zeroes=='h0000;})


  endtask

endclass:ieee_1149_10_raw_sequence

class ieee_1149_10_ch_select1_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_ch_select1_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_ch_select1_sequence");
    super.new(name);
  endfunction
  

  virtual task body();

    
   // `uvm_do_with(req,{req.cmd=='h05;req.scan_group=='h0001;req.ch_select=='h0001;req.channel_select=='h0001;})
    `uvm_do_with(req,{req.cmd=='h85;req.scan_group=='h0001;req.ch_select=='h0001;req.channel_select=='h0001;})


  endtask

endclass:ieee_1149_10_ch_select1_sequence


class ieee_1149_10_scan_sequence1#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_scan_sequence1#(pld_size)) 
  function new(string name = "ieee_1149_10_scan_sequence1");
    super.new(name);
	
  endfunction
  


  virtual task body();

    `uvm_do_with(req,{req.cmd=='h86;req.id=='h01;req.icsu=='h02;req.payload_frames=='h02;req.cycle_count=='h40;req.payload_size=='d64;})
    

  endtask

endclass:ieee_1149_10_scan_sequence1

class ieee_1149_10_scan_sequence2#(int pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet target_seq;


`uvm_object_param_utils(ieee_1149_10_scan_sequence2#(pld_size)) 
  function new(string name = "ieee_1149_10_scan_sequence2");
    super.new(name);
	
  endfunction
  

  virtual task body();

    `uvm_do_with(req,{req.cmd=='h86;req.id=='h02;req.icsu=='h02;req.payload_frames=='h04;req.cycle_count=='h62;req.payload_size=='d128;})  

  endtask

endclass:ieee_1149_10_scan_sequence2

class ieee_1149_10_wrong_crc_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet config_seq;
 logic[15:0] temp_cfg_target_id;

  `uvm_object_param_utils(ieee_1149_10_wrong_crc_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_wrong_crc_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_crc==1;})
     uvm_config_db#(logic[15:0])::set(null,"*","temp_cfg_target_id",req.cfg_target_id);

  endtask

endclass

class ieee_1149_10_wrong_format_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));
 
//  ieee_1149_10_packet config_seq;
 logic[15:0] temp_cfg_target_id;

  `uvm_object_param_utils(ieee_1149_10_wrong_format_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_wrong_format_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_format==1;})
     uvm_config_db#(logic[15:0])::set(null,"*","temp_cfg_target_id",req.cfg_target_id);

  endtask

endclass

class ieee_1149_10_opcode_error_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));

  `uvm_object_param_utils(ieee_1149_10_opcode_error_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_opcode_error_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_format==0;req.wrong_crc==0;req.wrong_cmd==1;})

  endtask

endclass

class ieee_1149_10_eop_error_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));

  `uvm_object_param_utils(ieee_1149_10_eop_error_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_eop_error_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_format==0;req.wrong_crc==0;req.wrong_cmd==0;req.wrong_eop==1;req.spcl_eop==0;})

  endtask

endclass

class ieee_1149_10_eop_error_spcl_data_sequence#(pld_size=128) extends uvm_sequence#(ieee_1149_10_packet#(pld_size));

  `uvm_object_param_utils(ieee_1149_10_eop_error_spcl_data_sequence#(pld_size)) 
  function new(string name = "ieee_1149_10_eop_error_spcl_data_sequence");
    super.new(name);
  endfunction
  

  virtual task body();
    
    `uvm_do_with(req,{req.cmd=='h81;req.wrong_format==0;req.wrong_crc==0;req.wrong_cmd==0;req.wrong_eop==0;req.spcl_eop==1;})

  endtask

endclass



 typedef  ieee_1149_10_config_sequence #(128) config_seq;
 typedef  ieee_1149_10_target_sequence #(128) target_seq;
typedef  ieee_1149_10_independent_target_sequence #(128) indpt_target_seq;
 typedef  ieee_1149_10_ch_select1_sequence #(128) ch_select1_seq;
 typedef  ieee_1149_10_reset_sequence #(128) reset_seq;
 typedef  ieee_1149_10_res_reset_sequence #(128) res_reset_seq; 
 typedef  ieee_1149_10_trs_reset_sequence #(128) trs_reset_seq;
 typedef  ieee_1149_10_raw_sequence #(128) raw_sequence;

typedef  ieee_1149_10_scan_sequence1 #(128) scan_sequence1;
typedef  ieee_1149_10_scan_sequence2 #(128) scan_sequence2;
typedef ieee_1149_10_wrong_crc_sequence #(128) wrong_crc_sequence;
typedef ieee_1149_10_wrong_format_sequence #(128) wrong_format_sequence;
typedef ieee_1149_10_opcode_error_sequence #(128) opcode_error_sequence;
typedef ieee_1149_10_eop_error_sequence #(128) eop_error_sequence;
typedef ieee_1149_10_eop_error_spcl_data_sequence #(128) eop_error_spcl_data_sequence;

class ieee_1149_10_packet#(int pld_size=128) extends uvm_sequence_item;

rand bit[7:0] sop; 
rand bit[31:0] eop;
rand bit[7:0] cmd;
rand bit[15:0] cfg_target_id;
rand bit[15:0] trg_target_id;
bit [31:0] crc32;
bit [23:0] payload;
rand bit[15:0] zeroes;
rand bit[15:0] packet_type;
rand bit[15:0] scan_group;
rand bit [15:0] ch_select;
rand bit[15:0] channel_select;
rand bit scan_payload[];
rand bit [7:0] id;
rand bit[7:0] icsu;
rand bit[31:0]  payload_frames;
rand bit[31:0]  cycle_count;
rand bit[15:0] lane;
  rand int payload_size;
  rand bit wrong_crc;
rand bit wrong_format;
rand bit wrong_cmd;
rand bit wrong_eop;
rand bit spcl_eop;

`uvm_object_param_utils_begin(ieee_1149_10_packet#(pld_size))
 `uvm_field_int(sop,UVM_ALL_ON)
 `uvm_field_int(eop,UVM_ALL_ON)
 `uvm_field_int(cmd,UVM_ALL_ON)
 `uvm_field_int(cfg_target_id,UVM_ALL_ON)
 `uvm_field_int(trg_target_id,UVM_ALL_ON)
 `uvm_field_int(packet_type,UVM_ALL_ON)
 `uvm_field_int(zeroes,UVM_ALL_ON)
 `uvm_field_int(scan_group,UVM_ALL_ON)
 `uvm_field_int(ch_select,UVM_ALL_ON)
 `uvm_field_int(channel_select,UVM_ALL_ON)
 `uvm_field_array_int(scan_payload,UVM_ALL_ON)
 `uvm_field_int(id,UVM_ALL_ON)
 `uvm_field_int(icsu,UVM_ALL_ON)
 `uvm_field_int(cycle_count,UVM_ALL_ON)
 `uvm_field_int(payload_frames,UVM_ALL_ON)
`uvm_field_int(lane,UVM_ALL_ON)
`uvm_field_int(crc32,UVM_ALL_ON)
  `uvm_field_int(payload_size,UVM_ALL_ON)
  `uvm_field_int(wrong_crc,UVM_ALL_ON)
`uvm_field_int(wrong_format,UVM_ALL_ON)
`uvm_field_int(wrong_cmd,UVM_ALL_ON)
`uvm_field_int(wrong_eop,UVM_ALL_ON)
`uvm_field_int(spcl_eop,UVM_ALL_ON)
`uvm_object_utils_end

function new(string name = "ieee_1149_10_packet");
	super.new(name);
endfunction 

constraint sop_fixed { sop == 8'hFB;}
constraint eop_fixed { eop == 32'hFDFDFDFD;}
constraint payload_frame_c{ scan_payload.size()== pld_size;}

endclass

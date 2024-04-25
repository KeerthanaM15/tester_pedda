class ieee_1149_10_sequencer#(int pld_size=128) extends uvm_sequencer#(ieee_1149_10_packet#(pld_size));

`uvm_component_param_utils(ieee_1149_10_sequencer#(pld_size))

//uvm_seq_item_pull_imp #(ieee_1149_10_packet#(pld_size),RSP,this_type) seq_item_export;

	function new(string name="ieee_1149_10_sequencer", uvm_component parent);
		super.new(name,parent);
	endfunction


endclass


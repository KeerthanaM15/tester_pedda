class ieee_1149_10_virtual_sequencer#(int pld_size=128) extends uvm_sequencer#(ieee_1149_10_packet#(pld_size));

  `uvm_component_param_utils(ieee_1149_10_virtual_sequencer#(pld_size))


  function new(string name="ieee_1149_10_virtual_sequencer", uvm_component parent);
		super.new(name,parent);
	endfunction
  
  ieee_1149_10_sequencer #(128) pedda_sqncr;


endclass


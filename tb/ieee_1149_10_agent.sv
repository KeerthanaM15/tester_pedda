class ieee_1149_10_agent#(int pld_size=128) extends uvm_agent;

	ieee_1149_10_sequencer #(pld_size) seqncr;
	ieee_1149_10_driver #(pld_size) driver;
	ieee_1149_10_monitor #(pld_size) monitor;

  `uvm_component_param_utils(ieee_1149_10_agent#(pld_size))

    function new(string name, uvm_component parent);
	super.new(name,parent);
	$display("agent_pld_size=%d",pld_size);
    endfunction

    virtual function void build_phase(uvm_phase phase);
	seqncr=ieee_1149_10_sequencer#(pld_size)::type_id::create("seqncr",this);
	driver=ieee_1149_10_driver#(pld_size)::type_id::create("driver",this);
//	monitor=ieee_1149_10_monitor#()::type_id::create("monitor",this);

	monitor=ieee_1149_10_monitor#(pld_size)::type_id::create("monitor",this);

    endfunction

    virtual function void connect_phase(uvm_phase phase);


	driver.seq_item_port.connect(seqncr.seq_item_export);
    endfunction


endclass


class ieee_1149_10_environment#(int pld_size=128) extends uvm_env;

	ieee_1149_10_agent #(pld_size) agent;
	ieee_1149_10_scoreboard #(pld_size) scoreboard;
	//ieee_1149_10_coverage #(pld_size) coverage;
  ieee_1149_10_virtual_sequencer v_sqncr;
	`uvm_component_param_utils(ieee_1149_10_environment#(pld_size))

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		agent=ieee_1149_10_agent#(pld_size)::type_id::create("agent",this);
		scoreboard=ieee_1149_10_scoreboard#(pld_size)::type_id::create("scoreboard",this);
      v_sqncr=ieee_1149_10_virtual_sequencer#(pld_size)::type_id::create("v_sqncr",this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect();
      agent.monitor.anp.connect(scoreboard.sb_analysis_imp);
	    //agent.monitor.anp2.connect(scoreboard.rx_item_collected_export);
	  //  agent.monitor.anp1.connect(coverage.cov_export);
	    //agent.monitor.anp2.connect(coverage.cov_export);
      v_sqncr.pedda_sqncr = agent.seqncr;
	endfunction

endclass


typedef ieee_1149_10_environment#(128) gen_env1;
typedef ieee_1149_10_environment#(128) gen_env2;




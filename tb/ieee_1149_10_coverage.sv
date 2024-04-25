//covergroup 1149_10_coverage();

class ieee_1149_10_coverage#(int pld_size=128) extends uvm_subscriber #(ieee_1149_10_packet#(pld_size));

`uvm_component_param_utils(ieee_1149_10_coverage#(pld_size));
 
uvm_analysis_imp #(ieee_1149_10_packet#(pld_size),ieee_1149_10_coverage#(pld_size)) cov_export;

ieee_1149_10_packet #(pld_size) packet;

covergroup ieee_1149_10_pkt_cov_cg;
      option.per_instance = 1;
	c1: coverpoint packet.sop { bins b1={'hFB};}
	c2: coverpoint packet.cmd	
	{ bins b2={'h01, 'h81, 'h02, 'h82, 'h03, 'h83, 'h04, 'h84, 'h05, 'h85, 'h06, 'h86};}

	c3: coverpoint packet.cfg_target_id	
	{ bins b3={'h0001};}

	c4: coverpoint packet.trg_target_id 
	{ bins b4={'h0001};}

	c5: coverpoint packet.id 
	{bins b5={'h0001};}
	
	c6: coverpoint packet.zeroes
	{bins b6={'h0000};}
	
	c7: coverpoint packet.scan_group
	{bins b7={'h0001}; }
	c8: coverpoint packet.ch_select 
	{bins b8={'h0001}; }
	c9: coverpoint packet.channel_select
	{bins b9={'h0001}; }
	
	c10: coverpoint packet.id
	{ bins b10={'h01};}
	c11: coverpoint packet.icsu
	{ bins b11={'h00};}
	c12: coverpoint packet.payload_frames
	{ bins b12={'h03};}
	c13: coverpoint packet.cycle_count
	{ bins b13={194};}

	c14: coverpoint packet.eop	
	{ bins b14={'hFDFDFDFD};}

 endgroup


 
function new(string name, uvm_component parent);
super.new(name, parent);

ieee_1149_10_pkt_cov_cg= new();

endfunction

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    cov_export=new("cov_export",this);
endfunction: build_phase
    
virtual function void write(ieee_1149_10_packet #(pld_size) t);

      packet=t;
	 
      ieee_1149_10_pkt_cov_cg.sample();

endfunction

endclass

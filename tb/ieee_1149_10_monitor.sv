class ieee_1149_10_monitor#(int pld_size=128) extends uvm_monitor;
  
  virtual ieee_1149_10_intf  vif;
  uvm_analysis_port #(bit [287:0]) anp;
 
  `uvm_component_param_utils(ieee_1149_10_monitor#(pld_size));
     
    
  function new(string name="ieee_1149_10_monitor", uvm_component parent);
    super.new(name,parent);
    anp=new("anp",this);
  endfunction: new
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!(uvm_config_db#(virtual ieee_1149_10_intf)::get(this, " ", "ieee_1149_10_intf",vif))) begin
      `uvm_fatal("NO VIF", "No virtual interface handle ") end
  endfunction: build_phase
  
  virtual task run_phase(uvm_phase phase);

    forever
      begin
        @(posedge vif.ieee_1149_10_clk);
        case(vif.cmd)
          8'b10000001: begin
            //$display("the config data is %h",vif.resp_config_data);
            anp.write(vif.resp_config_data);
          end
          8'b10000010: begin
            //$display("the target data is %h",vif.resp_target_data);
            anp.write(vif.resp_target_data);
          end
          8'b10000011: begin
            //$display("the target data is %h",vif.resp_target_data);
            anp.write(vif.resp_reset_data);
          end
          8'b10000100: begin
            //$display("the target data is %h",vif.resp_target_data);
            anp.write(vif.resp_raw_data);
          end
          8'b10000101: begin
            //$display("the target data is %h",vif.resp_target_data);
            anp.write(vif.resp_ch_sel_data);
          end
          8'b10000110: begin
            //$display("the target data is %h",vif.resp_target_data);
            if (vif.size==64)
              anp.write(vif.resp_scan_64_data);
            else if(vif.size==128)
              anp.write(vif.resp_scan_128_data);
          end
        endcase
      end
  endtask

endclass:ieee_1149_10_monitor

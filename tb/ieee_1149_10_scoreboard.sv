
class calc_parity_scb#(parameter int payload_size='d24);

static function  bit[31:0] crc32(input bit[payload_size-1:0] payload,input bit[32:0] divisor_t);

 int rsize;
 int n;
 int flag1;
 int m=0;
 int count;
 int k=0;
 int asize;
 int i;
 int j;
parameter divisor_size ='d33;
bit[divisor_size-2:0] crc_bits;
bit[divisor_size-1:0] divisor;

bit[payload_size+divisor_size-2:0] new_payload;
bit[payload_size+divisor_size-2:0] new_payload_t;

bit[payload_size+divisor_size-2:0] result;

rsize= (payload_size+divisor_size)-1;

divisor = {<<{divisor_t}};

//$display("received payload = %h",payload);
//$display("received payload size = %h",payload_size);
//$display("divisor = %h",divisor);


new_payload_t = {payload,{(divisor_size-1){1'b0}}};
new_payload = {<<{new_payload_t}};

//$display("new payload = %b",new_payload);


for(i=0;i<rsize;i++)
begin
	result[i]=new_payload[i];
end

//$display("result =%b",result);

for(i=0;i<divisor_size;i++)
begin
	result[i]= result[i]^divisor[i];
	n=i;
        
end

//	$display("result after first xor =%b",result);

while(n<=rsize)

	begin
	  while(flag1==0)
	  	begin
	    		if(result[m]==0 && m!=rsize)
	    		 m++;
            		else
             
	     		flag1=1;

	  	end
         		flag1=0;
 
	//	$display("value of n and m are n= %d, m=%d",n,m);

		      if( m+divisor_size <= rsize)

	
		  begin
	   		for(i=m;i<(divisor_size+m);i++)
	    		 begin
              			 result[i]=result[i]^divisor[k];
	     			  k++;
	    		 end
	   		  k=0;
		//	$display("result after  xor op = %b",result);
	 	 end
		    else
        	
		break;
        
         	n=(divisor_size+m)+1;	 

    	end
              
	j=divisor_size-2;
  //      $display(" rsize=%d", rsize);
//	$display(" j= %d",j);
     
	for(i=0;i< divisor_size-1;i++)
	begin
		new_payload[rsize-1]=result[rsize-1];
                crc_bits[j]= result[rsize-1];
                rsize--;
		j--;
	end
	

       return {<<{crc_bits}};


endfunction 


endclass

class ieee_1149_10_scoreboard#(int pld_size=128) extends uvm_scoreboard;

  uvm_analysis_imp#(bit [287:0],ieee_1149_10_scoreboard)sb_analysis_imp;
 
  bit [287:0]response_pkt;
  virtual ieee_1149_10_intf inf;
  int remainder;
  bit [287:0] storage_qu[$];
  bit [31:0]rx_crc32;

  `uvm_component_param_utils(ieee_1149_10_scoreboard#(pld_size))

  function new (string name="ieee_1149_10_scoreboard", uvm_component parent);
    super.new(name, parent);
  endfunction : new


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
	if(!uvm_config_db#(virtual ieee_1149_10_intf)::get(this,"","ieee_1149_10_intf",inf))
	`uvm_fatal("no_vif",{"virtual interface must be set for :",get_full_name(),"inf"});
    sb_analysis_imp  = new("tx_item_collected_export", this);
    
  endfunction: build_phase

  virtual function write(bit [287:0] tx_item_packet);
    storage_qu.push_back(tx_item_packet);
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    begin
      forever
        begin
          wait(storage_qu.size()>0);
      response_pkt=storage_qu.pop_front();
          
          if(inf.ieee_1149_10_parallel_in=='hfb) begin
      case(inf.cmd)
        8'h81:begin
$display("*********************************************************************************");
$display("                             CONFIG PACKET                                       ");
$display("*********************************************************************************");
              sop_check();
              cmd_check();
              target_id_check();
              config_crc32_check();
              eop_check();
        end
        8'h82:begin
$display("*********************************************************************************");
$display("                             TARGET PACKET                                       ");
$display("*********************************************************************************");

              sop_check();
              cmd_check();
              target_id_check();
              target_crc32_check();
              eop_check();
        end
        8'h83:begin
$display("*********************************************************************************");
$display("                             RESET PACKET                                       ");
$display("*********************************************************************************");

              sop_check();
              cmd_check();
              type_check();
              reset_crc32_check();
              eop_check();
        end
        8'h84:begin
$display("*********************************************************************************");
$display("                             RAW PACKET                                       ");
$display("*********************************************************************************");

              sop_check();
              cmd_check();
              raw_crc32_check();
              eop_check();
        end
        8'h85:begin
$display("*********************************************************************************");
$display("                             CHANNEL SELECT PACKET                                       ");
$display("*********************************************************************************");

          $display("the tx packet is %h",inf.temp_ch_sel_pkt);
          $display("the rx packet is %h",response_pkt);
              sop_check();
              cmd_check();
          scan_group_check();
          ch_sel_check();
          channel_select_check();
              ch_sel_crc32_check();
              eop_check();
        end
        8'h86:begin
$display("*********************************************************************************");
$display("                             SCAN PACKET                                       ");
$display("*********************************************************************************");

              sop_check();
              cmd_check();
          id_check();
          icsu_check();
          payload_frame_check();
          cycle_count_check();
              scan_crc32_check();
              eop_check();
        end
      endcase
          end
        end
    end
  endtask
  
  task sop_check();
    if((inf.temp_config_pkt[95:88]==response_pkt[95:88]) || (inf.temp_target_pkt[95:88]==response_pkt[95:88]) || (inf.temp_reset_pkt[95:88]==response_pkt[95:88]) || (inf.temp_raw_pkt[95:88]==response_pkt[95:88]) || (inf.temp_ch_sel_pkt[127:120]==response_pkt[127:120]) || (inf.temp_scan_64_pkt[223:216]==response_pkt[223:216]) || (inf.temp_scan_128_pkt[287:280]==response_pkt[287:280]))
      begin
        `uvm_info(get_type_name(),"SOP OF PACKETS MATCHED" , UVM_NONE)
        
      end
    else
      begin           
        `uvm_error(get_type_name(),"SOP OF PACKETS NOT MATCHED");
        $display("the unmatched data is %h %h",inf.temp_config_pkt[95:88],response_pkt[95:88]);
      end
	  
  endtask
  
  task cmd_check();
    if((inf.temp_config_pkt[87:80] == 8'h01 && response_pkt[87:80] == 8'h81) || (inf.temp_target_pkt[87:80] == 8'h02 && response_pkt[87:80] == 8'h82) || (inf.temp_reset_pkt[87:80] == 8'h03 && response_pkt[87:80] == 8'h83) || (inf.temp_raw_pkt[87:80] == 8'h04 && response_pkt[87:80] == 8'h84) || (inf.temp_ch_sel_pkt[119:112] == 8'h05 && response_pkt[119:112] == 8'h85) || (inf.temp_scan_64_pkt[215:208] == 8'h06 && response_pkt[215:208] == 8'h86) || (inf.temp_scan_128_pkt[279:272] == 8'h06 && response_pkt[279:272] == 8'h86))
      begin
        `uvm_info(get_type_name(),"CMD FIELD OF PACKETS MATCHED", UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(), "CMD FIELD OF PACKETS NOT MATCHED");
      end
	  
  endtask
  
  task target_id_check();
    if((inf.temp_config_pkt[79:64]==response_pkt[79:64]) || (inf.temp_target_pkt[79:64]==response_pkt[79:64]))
      begin
        `uvm_info(get_type_name(),"TARGET ID FIELD OF PACKETS MATCHED", UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),"TARGET ID FIELD OF PACKETS NOT MATCHED");
      end
  endtask
  
  task config_crc32_check();
    
    rx_crc32= calc_parity_scb #('d24)::crc32(response_pkt[87:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the config packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the config packet is corrupted"});
      end
  endtask
  
  task target_crc32_check();
    
    rx_crc32= calc_parity_scb #('d24)::crc32(response_pkt[87:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the target packet  is not corrupted",UVM_NONE)
      end
    else if(inf.error_id==1)
      begin
        `uvm_info(get_type_name(),"the target packet  is not corrupted with error id",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the target packet is corrupted"});
      end
  endtask
  
  task reset_crc32_check();
    
    rx_crc32= calc_parity_scb #('d24)::crc32(response_pkt[87:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the reset packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the reset packet is corrupted"});
      end
  endtask
  
  task raw_crc32_check();
    
    rx_crc32= calc_parity_scb #('d24)::crc32(response_pkt[87:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the raw packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the raw packet is corrupted"});
      end
  endtask
  
  task ch_sel_crc32_check();
    
    rx_crc32= calc_parity_scb #('d56)::crc32(response_pkt[119:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the ch_sel packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the ch_sel packet is corrupted"});
      end
  endtask
  
  task scan_crc32_check();
    if(inf.size==64) begin
    rx_crc32= calc_parity_scb #('d152)::crc32(response_pkt[215:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the scan packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the scan packet is corrupted"});
      end
    end
    else if(inf.size==128) begin
      rx_crc32= calc_parity_scb #('d216)::crc32(response_pkt[279:64],33'h104c11db7);
    if({<<byte{rx_crc32}} == response_pkt[63:32])
      begin
        `uvm_info(get_type_name(),"the scan packet  is not corrupted",UVM_NONE)
      end
    else
      begin
        `uvm_error(get_type_name(),{"the scan packet is corrupted"});
      end
    end
  endtask
      
  
  task eop_check();
    if((inf.temp_config_pkt[31:0]==response_pkt[31:0]) || (inf.temp_target_pkt[31:0]==response_pkt[31:0]) || (inf.temp_reset_pkt[31:0]==response_pkt[31:0]) || (inf.temp_raw_pkt[31:0]==response_pkt[31:0]) || (inf.temp_ch_sel_pkt[31:0]==response_pkt[31:0]) || (inf.temp_scan_64_pkt[31:0]==response_pkt[31:0]) || (inf.temp_scan_128_pkt[31:0]==response_pkt[31:0]))
      begin
        `uvm_info(get_type_name(),"EOP OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"EOP OF PACKETS NOT MATCHED");
      end
	  
  endtask
  
  task type_check();
    if(inf.temp_reset_pkt[79:64]==response_pkt[79:64])
      begin
        `uvm_info(get_type_name(),"RESET TYPE OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"RESET TYPE OF PACKETS NOT MATCHED");
      end
	  
  endtask
  
  task scan_group_check();
    if(inf.temp_ch_sel_pkt[111:96]==response_pkt[111:96])
      begin
        `uvm_info(get_type_name(),"SCAN GROUP OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"SCAN GROUP OF PACKETS NOT MATCHED");
      end
  endtask
  
  task ch_sel_check();
    if(inf.temp_ch_sel_pkt[95:80]==response_pkt[95:80])
      begin
        `uvm_info(get_type_name(),"CH SEL OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"CH SEL OF PACKETS NOT MATCHED");
      end
  endtask
  
  task channel_select_check();
    if(inf.temp_ch_sel_pkt[79:64]==response_pkt[79:64])
      begin
        `uvm_info(get_type_name(),"CHANNEL SELECT OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"CHANNEL SELECT OF PACKETS NOT MATCHED");
      end
  endtask
  
  task id_check();
    if(inf.size==64)
      begin
    if(inf.temp_scan_64_pkt[207:200]==response_pkt[207:200])
      begin
        `uvm_info(get_type_name(),"SCAN ID OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"SCAN ID OF PACKETS NOT MATCHED");
      end
      end
    else if(inf.size==128)
      begin
        if(inf.temp_scan_128_pkt[271:264]==response_pkt[271:264])
      begin
        `uvm_info(get_type_name(),"SCAN ID OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"SCAN ID OF PACKETS NOT MATCHED");
      end
      end
  endtask
  
  task icsu_check();
    if(inf.size==64) begin
    if(inf.temp_scan_64_pkt[199:192]==response_pkt[199:192])
      begin
        `uvm_info(get_type_name(),"ICSU OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"ICSU OF PACKETS NOT MATCHED");
      end
    end
    else if(inf.size ==128) begin
      if(inf.temp_scan_128_pkt[263:256]==response_pkt[263:256])
      begin
        `uvm_info(get_type_name(),"ICSU OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"ICSU OF PACKETS NOT MATCHED");
      end
    end
  endtask
  
  task payload_frame_check();
    if(inf.size==64) begin
    if(inf.temp_scan_64_pkt[191:160]==response_pkt[191:160])
      begin
        `uvm_info(get_type_name(),"PAYLOAD FRAME OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"PAYLOAD FRAME OF PACKETS NOT MATCHED");
      end
    end
    else if(inf.size==128) begin
      if(inf.temp_scan_128_pkt[255:224]==response_pkt[255:224])
      begin
        `uvm_info(get_type_name(),"PAYLOAD FRAME OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"PAYLOAD FRAME OF PACKETS NOT MATCHED");
      end
    end
  endtask
  
  task cycle_count_check();
    if(inf.size==64) begin
    if(inf.temp_scan_64_pkt[159:128]==response_pkt[159:128])
      begin
        `uvm_info(get_type_name(),"CYCLE COUNT OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"CYCLE COUNT OF PACKETS NOT MATCHED");
      end
    end
    else if(inf.size==128) begin
      if(inf.temp_scan_128_pkt[223:192]==response_pkt[223:192])
      begin
        `uvm_info(get_type_name(),"CYCLE COUNT OF PACKETS MATCHED" , UVM_NONE)
      end
    else
      begin           
        `uvm_error(get_type_name(),"CYCLE COUNT OF PACKETS NOT MATCHED");
      end
    end
  endtask

endclass

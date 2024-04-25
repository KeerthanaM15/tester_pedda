class calc_parity#(parameter int payload_size='d24);

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


class ieee_1149_10_driver#(int pld_size=128) extends uvm_driver#(ieee_1149_10_packet#(pld_size));
  
  `uvm_component_param_utils(ieee_1149_10_driver#(pld_size))
  virtual ieee_1149_10_intf inf;
  static	reg [15:0] cfg_target_stored;
	
  bit [15:0]reset_type;
  reg f = 0;
  int nop = 0;
  
  function new(string name="ieee_1149_10_driver",uvm_component parent);
    super.new(name, parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(virtual ieee_1149_10_intf)::get(this,"","ieee_1149_10_intf",inf))
      `uvm_fatal("no_vif",{"virtual interface must be set for :",get_full_name(),"inf"});
  endfunction
  
  task run_phase(uvm_phase phase);
    forever 
      begin
        ieee_1149_10_packet #(pld_size)   packet;

        seq_item_port.get_next_item(packet);
        begin
          wait(inf.reset)
          drive(packet);
        end 
        seq_item_port.item_done();
      end
  endtask
  
  task drive(ieee_1149_10_packet #(pld_size) packet);
    begin
      case(packet.cmd)
		// 'h01:drive_config_pkt(packet);
		 'h81:drive_configr_pkt(packet);
		 'h82:drive_targetr_pkt(packet);
		 'h83:drive_resetr_pkt(packet);
		 'h84:drive_rawr_pkt(packet);
		 'h85:drive_ch_selectr_pkt(packet);
		 'h86:drive_scanr_pkt(packet);
		 //'h07:drive_bond_pkt(packet);
		//default://drive_idle_pkt(packet);
		endcase	
		end
	endtask


  task drive_configr_pkt(ieee_1149_10_packet packet);
    
    reg [23:0]rx_payload;
    reg [23:0]tx_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    reset_type=0;
    $display("inside config packet driver ");

    rx_payload=inf.temp_config_pkt[87:64];
    rx_crc32= calc_parity #('d24)::crc32(rx_payload,33'h104c11db7);
    
    tx_payload={packet.cmd,16'h42};
    tx_crc32= calc_parity #('d24)::crc32(tx_payload,33'h104c11db7);
    inf.cmd = packet.cmd;
    if({<<byte{rx_crc32}} == inf.temp_config_pkt[63:32] && inf.temp_config_pkt[79:64]>0)
      begin
        if(packet.wrong_crc==1) begin
          //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~wrong crc~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
          inf.resp_config_data={packet.sop,packet.cmd,inf.temp_config_pkt[79:64],32'h32343638,packet.eop};
        end
	else if(packet.wrong_format==1)
	begin
	inf.resp_config_data={packet.cmd,packet.sop,inf.temp_config_pkt[79:64],{<<byte{tx_crc32}},packet.eop};
	end
	else if(packet.wrong_cmd==1)
	begin
	inf.resp_config_data={packet.sop,8'h61,inf.temp_config_pkt[79:64],{<<byte{tx_crc32}},packet.eop};
	end
	else if(packet.wrong_eop==1)
	begin
	inf.resp_config_data={packet.sop,packet.cmd,inf.temp_config_pkt[79:64],{<<byte{tx_crc32}},32'hfdfdfd};
	end
	else if(packet.spcl_eop==1)
	begin
	inf.resp_config_data={packet.sop,packet.cmd,inf.temp_config_pkt[79:64],{<<byte{tx_crc32}},32'hfddcbcfd};
	end

        else
          begin
            //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~no no wrong crc~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            inf.resp_config_data={packet.sop,packet.cmd,16'h42,{<<byte{tx_crc32}},packet.eop};
          end
        repeat(2) @(posedge inf.ieee_1149_10_clk);
      for(int i=11;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_config_data[8*i +:8];
             
              if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
    else
      begin
        inf.resp_config_data={packet.sop,packet.cmd,inf.temp_config_pkt[79:64],32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
      for(int i=11;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_config_data[8*i +:8];
                  
              if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
  endtask
  
  task drive_targetr_pkt(ieee_1149_10_packet packet);
    
    reg [23:0]rx_payload;
    reg [23:0]tx_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    $display("inside target packet driver ");

    rx_payload=inf.temp_target_pkt[87:64];
    rx_crc32= calc_parity #('d24)::crc32(rx_payload,33'h104c11db7);
    
    tx_payload={packet.cmd,inf.temp_target_pkt[79:64]};
    tx_crc32=calc_parity #('d24)::crc32(tx_payload,33'h104c11db7);
    
    if(reset_type=='h4)
      begin
        inf.temp_target_pkt[79:64]=0;
        inf.temp_config_pkt[79:64]=0;
      end
    inf.cmd = packet.cmd;
    if({<<byte{rx_crc32}} == inf.temp_target_pkt[63:32] && inf.temp_target_pkt[79:64]>0 && inf.temp_target_pkt[79:64]==inf.temp_config_pkt[79:64])
      begin
        inf.resp_target_data={packet.sop,packet.cmd,inf.temp_target_pkt[79:64],{<<byte{tx_crc32}},packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
    for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_target_data[8*i +:8];
                  
            if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        //if((inf.temp_target_pkt[79:64]!=inf.temp_config_pkt[79:64])|| (inf.temp_target_pkt[79:64]==0))
          inf.error_id=1;
        inf.resp_target_data={packet.sop,packet.cmd,inf.temp_target_pkt[79:64],32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
      for(int i=11;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_target_data[8*i +:8];
                 
              if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
  endtask

  task drive_resetr_pkt(ieee_1149_10_packet packet);
    
    reg [23:0]rx_payload;
    reg [23:0]tx_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    
    $display("inside reset packet driver ");

    rx_payload=inf.temp_reset_pkt[87:64];
    rx_crc32= calc_parity #('d24)::crc32(rx_payload,33'h104c11db7);
    
    tx_payload={packet.cmd,inf.temp_reset_pkt[79:64]};
    tx_crc32=calc_parity #('d24)::crc32(tx_payload,33'h104c11db7);
    inf.cmd = packet.cmd;
    if({<<byte{rx_crc32}} == inf.temp_reset_pkt[63:32])
      begin
        inf.resp_reset_data={packet.sop,packet.cmd,{<<byte{packet.packet_type}},{<<byte{tx_crc32}},packet.eop};
        reset_type=packet.packet_type;
        repeat(2) @(posedge inf.ieee_1149_10_clk);
    for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_reset_data[8*i +:8];
            
            if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        inf.resp_reset_data={packet.sop,packet.cmd,packet.packet_type,32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
      for(int i=11;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_reset_data[8*i +:8];
              if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
  endtask
  
  task drive_rawr_pkt(ieee_1149_10_packet packet);
   
    reg [23:0]rx_payload;
    reg [23:0]tx_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    
    $display("inside raw packet driver ");

    rx_payload=inf.temp_raw_pkt[87:64];
    rx_crc32= calc_parity #('d24)::crc32(rx_payload,33'h104c11db7);
    
    tx_payload={packet.cmd,inf.temp_raw_pkt[79:64]};
    tx_crc32=calc_parity #('d24)::crc32(tx_payload,33'h104c11db7);
    
   inf.cmd = packet.cmd;
    if({<<byte{rx_crc32}} == inf.temp_raw_pkt[63:32])
      begin
        inf.resp_raw_data={packet.sop,packet.cmd,{<<byte{packet.zeroes}},{<<byte{tx_crc32}},packet.eop};
        
        repeat(2) @(posedge inf.ieee_1149_10_clk);
    for(int i=11;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_raw_data[8*i +:8];
            if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        inf.resp_raw_data={packet.sop,packet.cmd,packet.zeroes,32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
      for(int i=11;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_raw_data[8*i +:8];
              if(i==11||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
  endtask

  
  task drive_ch_selectr_pkt(ieee_1149_10_packet packet);
    
    reg [55:0]rx_payload;
    reg [55:0]tx_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    
    $display("inside ch select packet driver ");

    rx_payload=inf.temp_ch_sel_pkt[119:64];
    rx_crc32= calc_parity #('d56)::crc32(rx_payload,33'h104c11db7);
    
    tx_payload={packet.cmd,inf.temp_ch_sel_pkt[111:64]};
    tx_crc32=calc_parity #('d56)::crc32(tx_payload,33'h104c11db7);
    inf.cmd = packet.cmd;
    if({<<byte{rx_crc32}} == inf.temp_ch_sel_pkt[63:32])
      begin
        inf.resp_ch_sel_data={packet.sop,packet.cmd,{<<byte{packet.scan_group}},{<<byte{packet.ch_select}},{<<byte{packet.channel_select}},{<<byte{tx_crc32}},packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=15;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_ch_sel_data[8*i +:8];
            
            if(i==15||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        inf.resp_ch_sel_data={packet.sop,packet.cmd,{<<byte{packet.scan_group}},{<<byte{packet.ch_select}}, {<<byte{packet.channel_select}},32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=15;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_ch_sel_data[8*i +:8];
              if(i==15||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
  endtask
  
	
  task drive_scanr_pkt(ieee_1149_10_packet#(pld_size) packet);
    
    reg [(159+64)-72:0]rx_64_payload;
    reg [(159+64)-72:0]tx_64_payload;
    reg [(159+128)-72:0]rx_128_payload;
    reg [(159+128)-72:0]tx_128_payload;
    reg [31:0]rx_crc32;
    reg [31:0]tx_crc32;
    int i=0;
    int j=0;
    $display("inside scan packet driver payload_size = %0d ",pld_size);

    if(packet.payload_size=='d128) begin
      inf.size=128;
    rx_128_payload=inf.temp_scan_128_pkt[279:64];
      rx_crc32= calc_parity #('d216)::crc32(rx_128_payload,33'h104c11db7);
    
      tx_128_payload={packet.cmd,inf.temp_scan_128_pkt[271:64]};
      tx_crc32=calc_parity #('d216)::crc32(tx_128_payload,33'h104c11db7);
    inf.cmd = packet.cmd;
      if({<<byte{rx_crc32}} == inf.temp_scan_128_pkt[63:32])
      begin
        inf.resp_scan_128_data={packet.sop,packet.cmd,packet.id,packet.icsu,{<<byte{packet.payload_frames}},{<<byte{packet.cycle_count}},inf.temp_scan_128_pkt[191:160],inf.temp_scan_128_pkt[159:128],inf.temp_scan_128_pkt[127:96],inf.temp_scan_128_pkt[95:64],{<<byte{tx_crc32}},packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=35;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_scan_128_data[8*i +:8];
            
            if(i==35||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        inf.resp_scan_128_data={packet.sop,packet.cmd,packet.id,packet.icsu,{<<byte{packet.payload_frames}},{<<byte{packet.cycle_count}},inf.temp_scan_128_pkt[191:160],inf.temp_scan_128_pkt[159:128],inf.temp_scan_128_pkt[127:96],inf.temp_scan_128_pkt[95:64],32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=35;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_scan_128_data[8*i +:8];
              if(i==35||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
    end
    else if(packet.payload_size=='d64)
      begin
        inf.size=64;
        rx_64_payload=inf.temp_scan_64_pkt[215:64];
        rx_crc32= calc_parity #('d152)::crc32(rx_64_payload,33'h104c11db7);
    
        tx_64_payload={packet.cmd,inf.temp_scan_64_pkt[207:64]};
        tx_crc32=calc_parity #('d152)::crc32(tx_64_payload,33'h104c11db7);
    
        if({<<byte{rx_crc32}} == inf.temp_scan_64_pkt[63:32])
      begin
        inf.resp_scan_64_data={packet.sop,packet.cmd,packet.id,packet.icsu,{<<byte{packet.payload_frames}},{<<byte{packet.cycle_count}},inf.temp_scan_64_pkt[127:96],inf.temp_scan_64_pkt[95:64],{<<byte{tx_crc32}},packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=27;i>=0;i--)
          begin
            @(posedge inf.ieee_1149_10_clk);
            inf.ieee_1149_10_parallel_in <=  inf.resp_scan_64_data[8*i +:8];
            
            if(i==27||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
          end
      end
    else
      begin
        inf.resp_scan_64_data={packet.sop,packet.cmd,packet.id,packet.icsu,{<<byte{packet.payload_frames}},{<<byte{packet.cycle_count}},inf.temp_scan_64_pkt[127:96],inf.temp_scan_64_pkt[95:64],32'hFEFEFEFE,packet.eop};
        repeat(2) @(posedge inf.ieee_1149_10_clk);
        for(int i=27;i>=0;i--)
            begin
              @(posedge inf.ieee_1149_10_clk);
              inf.ieee_1149_10_parallel_in <=  inf.resp_scan_64_data[8*i +:8];
              if(i==27||i<=3)
            inf.tb_k_in<=1;
          else
            inf.tb_k_in<=0;
            end
      end
      end
  endtask
endclass


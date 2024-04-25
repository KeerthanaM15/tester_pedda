`timescale 1ns/1ps
`include "ieee_1149_10_intf.sv"
`include "ieee_1149_10_encoder.sv"
`include "ieee_1149_10_decoder.sv"
`include "tb_encoder_8b10b.sv"
`include "tb_decoding_10b8b.sv"


module top;

reg sys_clk;
reg sys_rst;
wire [9:0]encoded_value_in;
wire [9:0]encoded_value_in_t;
wire [9:0]encoded_value_out;
wire [7:0]decoded_out;

import uvm_pkg::*;
import ieee_1149_tb_pkg::*;




initial
begin

sys_clk=0;
forever #5 sys_clk = ~sys_clk;
end

initial
begin

sys_rst=0;
repeat(2)@(posedge sys_clk);
sys_rst=1;
end

 ieee_1149_10_intf inf(sys_clk,sys_rst);
  

tb_encoder_8b10b tb_encoder(.clk(sys_clk),.rst_n(sys_rst),.k_in(inf.tb_k_in),.data_in(inf.ieee_1149_10_parallel_in),.k_err(),.data_out(encoded_value_in));


decoding_10b8b_tb  tb_decode(.clk(sys_clk),.data_in(encoded_value_out),.rdisp_in(),.code_err(),.disp_err(),.k_out(),.data_out(inf.ieee_1149_10_parallel_out));




jtag_1149_d10_master DUT ( .clk(sys_clk), .rst_n(sys_rst), .jtag_1149_d10_mstr_data_in(encoded_value_in), .pedda_mst_status1_out(inf.pedda_mst_status1_out), .dbg_mux_out(), .jtag_1149_d10_mstr_data_out(encoded_value_out), .sram_rd_data(inf.sram_rd_data),.sram_addr(inf.sram_addr)
);
;



initial begin

	uvm_config_db#(virtual ieee_1149_10_intf)::set(null,"*","ieee_1149_10_intf",inf);
	$dumpfile("dump.vcd");
	$dumpvars();
	end

initial
begin
run_test();
#10000ns;
$finish();

end



endmodule

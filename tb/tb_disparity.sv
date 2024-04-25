////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Wednesday 04 Jan 2023 10:15:00 IST              *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: running disparity check for Encoder module     *////
////////////////////////////////////////////////////////////////////////

module tb_disparity(clk,
                 rst_n,
                 data_in,
                 disp_out);

  input        clk;      //clock for disparity check
  input        rst_n;    //active low reset
  input  [9:0] data_in;  //data input from 8b10b
  output wire  disp_out; //disparity output		 
  input        clk;      //clock for disparity check
  input        rst_n;    //active low reset

  parameter RD_MINUS = 1;
  parameter RD_PLUS  = 0;
  
  reg cs;
  reg ns;
  
  reg [3:0] rd;
  reg [3:0] ones;
  
  assign disp_out = cs;
  
  function [3:0] no_ones;
    input [9:0] data_in_10b;
    input [3:0] counter;
    reg [3:0] counter1;

    integer index;
      begin 
        counter1 = counter;
        for(index = 0;index < 10;index = index+1)
          begin
            if(data_in_10b[index] == 1'b1)
              begin
                counter1 = counter1+1;
              end
            else
              begin
                counter1 = counter1;
              end
          end
        
        no_ones = counter1;
      end
  endfunction
  
  always@(cs,rst_n,data_in)
    begin
	if(!rst_n)
	  begin
            ns = 0;
	  end
	else
	  begin
          ones = no_ones(data_in,0);
          case(cs)
            RD_MINUS:
              begin
                rd = ones - (10-ones);
                if(rd == 0)
                  ns = RD_MINUS;
                else
                  ns = RD_PLUS;
              end
            RD_PLUS:
              begin
                rd = ones - (10-ones);
                if(rd == 0)
                  ns = RD_PLUS;
                else
                  ns = RD_MINUS;
              end
          endcase
			  end
    end
  
  always @ (posedge clk or negedge rst_n)
    begin
      if(!rst_n)
        begin
          cs <= 1'b1;
        end
      else
        begin
          cs <= ns;
        end
    end
endmodule



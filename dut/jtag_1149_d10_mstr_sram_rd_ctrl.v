/////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.          *////
////*  Author: rufina.jasni                                         *////
////*  Department: CoE                                              *////
////*  Created on: Monday 12 Feb 2024 10:53:00 IST                  *////
////*  Project: IEEE1149.10 IP Design                               *////
////*  Module: jtag_1149_d10_mstr_sram_rd_cntrl                     *////
////*  Submodule: Nil                                               *////
////*  Description: SRAM controller to read from BRAM file          *////
/////////////////////////////////////////////////////////////////////////

                                                                    
module jtag_1149_d10_mstr_sram_rd_ctrl
  #(
  parameter SRAMD_WIDTH        = 32,
  parameter SRAMA_WIDTH        = 10,
  parameter CH_SEL_WIDTH       = 8,
  parameter BYTE_WIDTH         = 8,
  parameter WORD_WIDTH         = 16,
  parameter NIBBLE_WIDTH       = 4

  )
  (
       //SRAM_rd_cntrl signls to read data (6 signals)
       input                          clk,
       input                          rst_n,
       output reg[SRAMA_WIDTH-1:0]    sram_addr,
       input [SRAMD_WIDTH-1:0]        sram_rd_data,
       output reg                     sram_we,
       output reg[SRAMD_WIDTH-1:0]    sram_wr_data,

       //Between tx_cntrl & SRAM_rd_cntrl (22 signals)
       input                          read_next_loc,
       input                          comp_char_done,
       output reg                     start_op_dtctd,       // To tx_cntrl after START_OP detection to send compliance char
       output reg                     send_pkt_vld,
       output reg [BYTE_WIDTH-1:0]    send_pkt_type,
       output reg [WORD_WIDTH-1:0]    send_target_id,
       output reg [WORD_WIDTH-1:0]    send_reset_value,
       output reg [WORD_WIDTH-1:0]    send_raw_value,
       output reg [CH_SEL_WIDTH-1:0]  send_ch_sel,

       output reg [BYTE_WIDTH-1:0]    scan_pkt_id,
       output reg [NIBBLE_WIDTH-1:0]  scan_pkt_icsu,
       output reg [NIBBLE_WIDTH-1:0]  scan_pkt_payld_frame,
       output reg [BYTE_WIDTH-1:0]    scan_pkt_cycle_count,
       input                          scan_instr_processed,  //Acknowledgement from tx_cntrl after recieving scan_pkt
       output reg                     test_ptrn_data_vld,
       output reg [SRAMD_WIDTH-1:0]   test_ptrn_data,
       output reg                     test_ptrn_data_last,

       input                          enter_lpbk,
       output reg                     raw_data_vld,
       output reg [SRAMD_WIDTH-1:0]   send_raw_data,
       output reg                     exit_lpbk_mode,

       output reg                     ptrn_end             //EOP detected
              );

  reg[6:0]                counter;
  reg[2:0]                state;
  reg[NIBBLE_WIDTH-1:0]   btb_rd_count;
  reg                     d_cycle_count;
  reg[SRAMA_WIDTH-1:0]    sram_new_addr;
  reg                     scan_pkt_dtctd;
  reg                     raw_pkt_dtctd;  
  reg                     roll_ovr_dtctd;      
    
  localparam IDLE           = 3'b000;
  localparam SRAM_ADDR_INCR = 3'b001;
  localparam PLACE_NEW_ADDR = 3'b010;
  localparam RD_DECODE_ST   = 3'b011;
  localparam WAIT           = 3'b100;
  localparam WRITE_ST       = 3'b101;
   
   //counter module to count 0 to 99
  always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
   counter      <= 7'd0;
   end
   else begin
     if (counter<7'h64) begin
       counter  <= counter+7'd1;
     end
     else begin
       counter  <= 7'd0;
     end
   end
  end
   
  always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
      sram_we              <= 1'd0; 
      sram_addr            <= 10'd0;
      sram_wr_data         <= 32'd0; 
      send_pkt_vld         <= 1'd0;
      send_pkt_type        <= 8'd0;
      send_target_id       <= 16'd0;
      send_reset_value     <= 16'd0;
      send_raw_value       <= 16'd0;
      send_ch_sel          <= 8'd0;
      scan_pkt_id          <= 8'd0;
      scan_pkt_icsu        <= 4'd0;
      scan_pkt_payld_frame <= 4'd0;
      scan_pkt_cycle_count <= 8'd0;
      test_ptrn_data_vld   <= 1'd0;
      test_ptrn_data       <= 32'd0;
      test_ptrn_data_last  <= 1'd0;
      ptrn_end             <= 1'd0;
      raw_data_vld         <= 1'd0;
      send_raw_data        <= 32'd0;
      exit_lpbk_mode       <= 1'd0;
      start_op_dtctd       <= 1'd0;
      roll_ovr_dtctd       <= 1'd0;
      scan_pkt_dtctd       <= 1'd0; 
      raw_pkt_dtctd        <= 1'd0;
      btb_rd_count         <= 4'd0;
      d_cycle_count        <= 1'd0;
      sram_new_addr        <= 10'd0;
      state                <= IDLE;
      counter              <= 7'h0;
    end
  else begin
   case (state)
     IDLE         : begin  
                       if(counter==7'h63) begin
                         if(sram_rd_data[7:0]==8'h08) begin  // 0x8 - ST_OP
                           start_op_dtctd         <= 1'b1;
                           state                  <= WRITE_ST;
                         end
                         else begin
                           start_op_dtctd         <= 1'b0;   // Remain in IDLE
                           state                  <= IDLE;
                         end       
                       end
                       else begin
                      //   counter <=counter+7'h1;
                         btb_rd_count             <= 4'd0;
                         d_cycle_count            <= 1'd0;
                         exit_lpbk_mode           <= 1'd0;
                         state                    <= IDLE;
                       end
                     end

      SRAM_ADDR_INCR: begin
                       sram_we                    <= 1'd0;
                       start_op_dtctd             <= 1'd0;
                       test_ptrn_data_vld         <= 1'd0;
                       sram_new_addr              <= sram_new_addr+10'd1; 
                       state                      <= PLACE_NEW_ADDR;
                      end

      PLACE_NEW_ADDR: begin
                       sram_addr                  <= sram_new_addr;
                       d_cycle_count              <= 1'b0; 
                       state                      <= RD_DECODE_ST;
                     end   

      RD_DECODE_ST:   begin
                      if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h01) begin       //CONFIG
                        if(comp_char_done) begin
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        send_target_id            <= sram_rd_data[23:8];
                        state                     <= WAIT;
                        end
                        else begin
                          send_pkt_vld              <= 1'b0;
                          state                     <=RD_DECODE_ST;
                        end
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h02) begin  //TARGET
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        send_target_id            <= sram_rd_data[23:8];
                        state                     <= WAIT;
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h03) begin  //RESET
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        send_reset_value          <= sram_rd_data[23:8];
                        state                     <= WAIT;
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h04) begin   //RAW
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        send_raw_value            <= sram_rd_data[23:8]; 
                        raw_pkt_dtctd             <= 1'b1;
                        state                     <= WAIT;
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h05) begin  //CH_SEL
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        send_ch_sel               <= sram_rd_data[15:8];
                        state                     <= WAIT;
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h06) begin  //SCAN
                        send_pkt_vld              <= 1'b1;
                        send_pkt_type             <= sram_rd_data[7:0];
                        scan_pkt_cycle_count      <= sram_rd_data[15:8];
                        scan_pkt_payld_frame      <= sram_rd_data[19:16];
                        scan_pkt_icsu             <= sram_rd_data[23:20];
                        scan_pkt_id               <= sram_rd_data[31:24];
                        scan_pkt_dtctd            <= 1'b1;  
                        state                     <= WAIT;
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h07) begin  //EOP
                        ptrn_end                  <= 1'd1;
                        if(send_pkt_type == 8'h4) begin
                          exit_lpbk_mode          <= 1'b1;
                          raw_pkt_dtctd           <= 1'b0;
                          raw_data_vld            <= 1'b0;
                          state                   <= IDLE;
                        end
                        else begin
                          exit_lpbk_mode          <= 1'b0;
                          state                   <= IDLE;
                        end
                      end
                      else if(~raw_pkt_dtctd && ~scan_pkt_dtctd && sram_rd_data[7:0]==8'h09) begin  //ROLL OVER
                        roll_ovr_dtctd            <= 1'b1;
                        state                     <= WRITE_ST; 
                      end
                      else if(scan_pkt_dtctd) begin         // If scan packet is detected & processed, send back to back data based on #payload frame
                        if(scan_pkt_payld_frame==4'd1 && btb_rd_count==4'd0) begin        //#payload frame =1
                         if(d_cycle_count==1'b1) begin
                           test_ptrn_data_vld     <= 1'b1;
                           test_ptrn_data_last    <= 1'b1;
                           test_ptrn_data         <= sram_rd_data;
                           scan_pkt_dtctd         <= 1'b0;
                           state                  <= WAIT;
                         end
                         else begin
                          d_cycle_count           <= d_cycle_count+1'b1;
                          state                   <= RD_DECODE_ST;
                         end
                        end
                        else if(scan_pkt_payld_frame==4'd2 && btb_rd_count<=4'd1) begin   //#payload frame =2
                         if(d_cycle_count==1'b1) begin
                          test_ptrn_data_vld      <= 1'b1;
                          test_ptrn_data          <= sram_rd_data;
                          d_cycle_count           <= d_cycle_count+1'b1;
                          if(btb_rd_count==4'd1) begin
                            test_ptrn_data_last   <= 1'b1;
                            scan_pkt_dtctd        <= 1'b0;
                            btb_rd_count          <= 4'd0;
                            state                 <= WAIT;
                          end
                          else begin
                            test_ptrn_data_last   <= 1'd0;
                            btb_rd_count          <= btb_rd_count+4'd1;
                            state                 <= SRAM_ADDR_INCR;
                          end
                         end
                         else begin
                          d_cycle_count           <= d_cycle_count+1'b1;
                          state                   <= RD_DECODE_ST;
                         end
                       end
                      else if(scan_pkt_payld_frame==4'd3 && btb_rd_count<=4'd2) begin    //#payload frame =3
                        if(d_cycle_count==1'b1) begin
                         test_ptrn_data_vld       <= 1'b1;
                         test_ptrn_data           <= sram_rd_data;
                         d_cycle_count           <= d_cycle_count+1'b1;
                         if(btb_rd_count==4'd2) begin
                           test_ptrn_data_last    <= 1'b1;
                           scan_pkt_dtctd         <= 1'b0;
                           btb_rd_count           <= 4'd0;
                           state                  <= WAIT;
                         end
                         else begin
                           test_ptrn_data_last    <= 1'd0;
                           btb_rd_count           <= btb_rd_count+4'd1;
                           state                  <= SRAM_ADDR_INCR;
                         end
                        end
                        else begin
                          d_cycle_count           <= d_cycle_count+1'b1;
                          state                   <= RD_DECODE_ST;
                        end
                     end
                     else if(scan_pkt_payld_frame==4'd4 && btb_rd_count<=4'd3) begin     //#payload frame =4
                       if(d_cycle_count==1'b1) begin
                         test_ptrn_data_vld       <= 1'b1;
                         test_ptrn_data           <= sram_rd_data;
                         d_cycle_count           <= d_cycle_count+1'b1;
                         if(btb_rd_count==4'd3) begin
                           test_ptrn_data_last    <= 1'b1;
                           scan_pkt_dtctd         <= 1'b0;
                           btb_rd_count           <= 4'd0;
                           state                  <= WAIT;
                         end
                         else begin
                           test_ptrn_data_last    <= 1'd0;
                           btb_rd_count           <= btb_rd_count+4'd1;
                           state                  <= SRAM_ADDR_INCR;
                         end
                       end
                       else begin
                         d_cycle_count            <= d_cycle_count+1'b1;
                         state                    <= RD_DECODE_ST;
                       end
                     end
                   end
 
                   else if(raw_pkt_dtctd) begin
                       if(d_cycle_count==1'b1) begin   
                         raw_pkt_dtctd            <= 1'b0;
                         raw_data_vld             <= 1'b1;              //RAW data
                         send_raw_data            <= sram_rd_data;
                         state                    <= SRAM_ADDR_INCR;
                       end
                       else begin
                         d_cycle_count            <= d_cycle_count+1'b1;
                         raw_pkt_dtctd            <= 1'b0;
                         state                    <= RD_DECODE_ST;
                       end   
                   end
                   else begin
                     state                        <= RD_DECODE_ST;
                   end
                   end

         
     WAIT         : begin
                    send_pkt_vld                  <= 1'd0;
                    test_ptrn_data_vld            <= 1'd0;
                    test_ptrn_data_last           <= 1'd0;
                      if(read_next_loc | enter_lpbk | scan_instr_processed) begin                  
                        state                     <= SRAM_ADDR_INCR;
                      end
                      else begin
                        state                     <= WAIT;
                      end
                    end

     WRITE_ST      : begin
                        sram_new_addr             <= sram_addr;
                       if(start_op_dtctd) begin
                         sram_we                  <= 1'b1;
                         sram_wr_data             <= 32'h0c;
                         state                    <= SRAM_ADDR_INCR;
                       end
                       else if(roll_ovr_dtctd) begin
                         counter                  <= 7'h0;
                         roll_ovr_dtctd           <= 1'b0;
                         sram_we                  <= 1'b1;
                         sram_wr_data             <= 32'h0d;
                         state                    <= IDLE;
                       end
                     end

     default       : begin
                      state                       <= IDLE;
                      test_ptrn_data_vld          <= 1'd0;
                      test_ptrn_data_last         <= 1'd0;
                      raw_data_vld                <= 1'd0;
                    end
   endcase
  end
 end
endmodule




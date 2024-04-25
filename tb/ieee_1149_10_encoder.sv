module encoder_8b10b_tb(
		  
   // --- Resets
   input reset,

   // --- Clocks
   input SBYTECLK,
		  
   // --- Control (K) input	  
   input K,
		  
   // --- Eight Bt input bus	  
   input [7:0] ebi,
		
   // --- TB (Ten Bt Interface) output bus
   output [9:0] tbi,

   output reg disparity
   );

  
   // Figure 3 - Encoder: 5B/6B classification, L functions
   wire   L40, L04, L13, L31, L22, AeqB, CeqD;

   // Figure 5 - 5B/6B Encoder: disparity classifications
   wire   PD_1S6, NDOS6, PDOS6, ND_1S6;

   // Figure 5 - 3B/4B Encoder: disparity classifications
   wire   ND_1S4, PD_1S4, NDOS4, PDOS4;

   // Figure 6 - Encoder: control of complementation
   wire   illegalk, DISPARITY6;
   reg    COMPLS6, COMPLS4;

   // Figure 7 - 5B/6B encoding 
   wire   NAO, NBO, NCO, NDO, NEO, NIO;
   
   // Figure 8: 3B/4B encoding
   wire   NFO, NGO, NHO, NJO;

   // 8B Inputs
   wire   A,B,C,D,E,F,G,H;      
 
   assign {H,G,F,E,D,C,B,A} = ebi[7:0];
 
   // 10B Outputs
   reg 	  a,b,c,d,e,i,f,g,h,j; 
  
   assign tbi[9:0] = {a,b,c,d,e,i,f,g,h,j};

   wire [9:0] tst;
   
   assign tst[9:0] = {NAO,NBO,NCO,NDO,NEO,NIO,NFO,NGO,NHO,NJO};
  
   // ******************************************************************************
   // Figures 7 & 8 - Latched 5B/6B and 3B/4B encoder outputs 
   // ******************************************************************************
   
   always @(posedge SBYTECLK, posedge reset)
     if (reset) 
       begin
	  disparity <= 1'b0; {a,b,c,d,e,i,f,g,h,j} <= 10'b0; 
       end 
     else begin
       	
	disparity <= (PDOS4 | NDOS4) ^ DISPARITY6;
	
	{a,b,c,d,e,i,f,g,h,j} <= { NAO^COMPLS6, NBO^COMPLS6, NCO^COMPLS6, 
				   NDO^COMPLS6, NEO^COMPLS6, NIO^COMPLS6,
				   NFO^COMPLS4, NGO^COMPLS4, 
				   NHO^COMPLS4, NJO^COMPLS4 };	
     end // else: !if(reset)
    
   // ******************************************************************************
   // Figure 3 - Encoder: 5B/6B classification, L functions
   // ******************************************************************************
   
   assign AeqB = (A & B) | (!A & !B);
   assign CeqD = (C & D) | (!C & !D);
   
   assign L40 =  A & B & C & D ;
   assign L04 = !A & !B & !C & !D;
   
   assign L13 = (!AeqB & !C & !D) | (!CeqD & !A & !B);
   assign L31 = (!AeqB &  C &  D) | (!CeqD &  A &  B);
   assign L22 = (A & B & !C & !D) | (C & D & !A & !B) | ( !AeqB & !CeqD) ;
   
   // ******************************************************************************
   // Figure 5 - 5B/6B Encoder: disparity classifications
   // ******************************************************************************
     
   assign PD_1S6 = (E & D & !C & !B & !A) | (!E & !L22 & !L31) ;

   //assign PD_1S6 = (L13 & D & E) | (!E & !L22 & !L31) ;
   
   assign NDOS6  = PD_1S6 ;
   assign PDOS6  = K | (E & !L22 & !L13) ;
   assign ND_1S6 = K | (E & !L22 & !L13) | (!E & !D & C & B & A) ;
  
   // ******************************************************************************
   // Figure 5 - 3B/4B Encoder: disparity classifications
   // ******************************************************************************
    
   assign ND_1S4 = F & G ;
   assign NDOS4  = (!F & !G) ;
   assign PD_1S4 = (!F & !G) | (K & ((F & !G) | (!F & G)));
   assign PDOS4  = F & G & H ;
   
   // ******************************************************************************
   // Figure 6 - Encoder: control of complementation
   // ******************************************************************************

   // not K28.0->7 & K23/27/29/30.7
   assign illegalk = K & (A | B | !C | !D | !E) & (!F | !G | !H | !E | !L31); 

   assign DISPARITY6 = disparity ^ (NDOS6 | PDOS6) ;

   always @(posedge SBYTECLK, posedge reset)
     if(reset) begin
       COMPLS4 <= 0;
       COMPLS6 <= 0;
       end
     else begin
       COMPLS4 <= (PD_1S4 & !DISPARITY6) | (ND_1S4 & DISPARITY6);
       COMPLS6 <= (PD_1S6 & !disparity) | (ND_1S6 & disparity);
       end
 
   // ******************************************************************************
   // Figure 7 - 5B/6B encoding 
   // ******************************************************************************

   reg tNAO, tNBOx, tNBOy, tNCOx, tNCOy, tNDO , tNEOx, tNEOy, tNIOw, tNIOx, tNIOy, tNIOz;

   always @(posedge SBYTECLK, posedge reset)
     if(reset) begin
       tNAO  <= 0;
       tNBOx <= 0;
       tNBOy <= 0;
       tNCOx <= 0;
       tNCOy <= 0;
       tNDO  <= 0;
       tNEOx <= 0;
       tNEOy <= 0;
       tNIOw <= 0;
       tNIOx <= 0;
       tNIOy <= 0;
       tNIOz <= 0;
       end
     else begin
       tNAO  <= A ;

       tNBOx <= B & !L40;
       tNBOy <= L04 ;

       tNCOx <= L04 | C ;
       tNCOy <= E & D & !C & !B & !A ;

       tNDO  <= D & ! (A & B & C) ;

       tNEOx <= E | L13;
       tNEOy <= !(E & D & !C & !B & !A) ;

       tNIOw <= (L22 & !E) | (E & L40) ;
       tNIOx <= E & !D & !C & !(A & B) ;
       tNIOy <= K & E & D & C & !B & !A ;
       tNIOz <= E & !D & C & !B & !A ;
       end

   assign NAO = tNAO ;
   assign NBO = tNBOx | tNBOy ;
   assign NCO = tNCOx | tNCOy ;
   assign NDO = tNDO ;
   assign NEO = tNEOx & tNEOy ;
   assign NIO = tNIOw | tNIOx | tNIOy | tNIOz;
   
   // ******************************************************************************
   // Figure 8: 3B/4B encoding
   // ******************************************************************************

   reg alt7, tNFO, tNGO, tNHO, tNJO;

   always @(posedge SBYTECLK, posedge reset)
     if(reset) begin
       alt7 <= 0;
       tNFO <= 0;
       tNGO <= 0;
       tNHO <= 0;
       tNJO <= 0;
       end
     else begin
       alt7 <= F & G & H & (K | (disparity ? (!E & D & L31) : (E & !D & L13))) ;
       tNFO <= F;
       tNGO <= G | (!F & !G & !H) ;
       tNHO <= H ;
       tNJO <= !H & (G ^ F) ;
       end

   assign NFO = tNFO & !alt7 ;
   assign NGO = tNGO ;
   assign NHO = tNHO ;
   assign NJO = tNJO | alt7 ;

endmodule


module decoder_8b10b_tb(
		  
   // --- Resets ---
   input reset,

   // --- Clocks ---
   input RBYTECLK,
		  
   // --- TBI (Ten Bit Interface) input bus
   input [9:0] tbi,

   // --- Control (K)
   output reg K_out,
		  
   // -- Eight bit output bus
   output reg [7:0] ebi,

   // --- 8B/10B RX coding error ---
   output reg coding_err,
		 
   // --- 8B/10B RX disparity ---
   output reg disparity,
   
   // --- 8B/10B RX disparity error ---
   output disparity_err
  
  );
   
`ifdef MODEL_TECH
   // ModelSim debugging only 
   wire [4:0] decoder_8b_X;  wire [2:0] decoder_8b_Y;
   
   assign     decoder_8b_X = ebi[4:0];
   assign     decoder_8b_Y = ebi[7:5];
`endif    
   
   wire   a,b,c,d,e,i,f,g,h,j;  // 10 Bit inputs
 
   assign {a,b,c,d,e,i,f,g,h,j} = tbi[9:0];
   
   // ******************************************************************************
   // Figure 10 - Decoder: 6b - Signals
   // ******************************************************************************
   wire 	AEQB, CEQD, P22, P13, P31;
   
   // ******************************************************************************
   // Figure 11 - Decoder: K - Signals
   // ******************************************************************************
   
   wire 	eeqi, c_d_e_i, cn_dn_en_in;
   
   wire 	P22_a_c_eeqi, P22_an_cn_eeqi;
   
   wire 	P22_b_c_eeqi, P22_bn_cn_eeqi, an_bn_en_in;
   
   wire 	a_b_e_i, P13_d_e_i, P13_in, P13_en, P31_i;

   // ******************************************************************************
   // Figure 12 - Decoder: 5B - Signals   
   // ******************************************************************************
   
   wire 	OR12_1, OR12_2, OR12_3, OR12_4, OR12_5, OR12_6, OR12_7;
   
   wire 	A, B, C, D, E;

   // ******************************************************************************
   // Figure 13 - Decoder: 3B - Signals
   // ******************************************************************************
   
   wire  	K, F, G, H, K28p, KA, KB, KC;
   
   // ******************************************************************************
   // Figure 10 - Decoder: 6b Input Function
   // ******************************************************************************

   assign 	AEQB = (a & b) | (!a & !b) ;
   assign 	CEQD = (c & d) | (!c & !d) ;
   assign 	P22 = (a & b & !c & !d) | (c & d & !a & !b) | ( !AEQB & !CEQD) ;
   assign 	P13 = ( !AEQB & !c & !d) | ( !CEQD & !a & !b) ;
   assign 	P31 = ( !AEQB & c & d) | ( !CEQD & a & b) ;
   
   // ******************************************************************************
   // Figure 11 - Decoder: K 
   // ******************************************************************************
   
   assign 	eeqi = (e == i);
   
   assign 	P22_a_c_eeqi   = P22 & a & c & eeqi;
   assign 	P22_an_cn_eeqi = P22 & !a & !c & eeqi;

   assign 	cn_dn_en_in = (!c & !d & !e & !i);
   assign 	c_d_e_i     = (c & d & e & i);
   
   assign 	KA = c_d_e_i | cn_dn_en_in;
   assign 	KB = P13 & (!e & i & g & h & j);
   assign 	KC = P31 & (e & !i & !g & !h & !j);
   
   assign 	K = KA | KB | KC;

   assign 	P22_b_c_eeqi   = P22 & b & c & eeqi;
   assign 	P22_bn_cn_eeqi = P22 & !b & !c & eeqi;
   assign 	an_bn_en_in    = !a & !b & !e & !i;
   assign 	a_b_e_i        = a & b & e & i;
   assign 	P13_d_e_i      = P13 & d & e & i;
   assign 	P13_in         = P13 & !i;
   assign 	P13_en         = P13 & !e;
   assign 	P31_i          = P31 & i;


   // ******************************************************************************
   // Figure 12 - Decoder: 5B/6B
   // ******************************************************************************

   assign 	OR12_1 = P22_an_cn_eeqi | P13_en;
   assign 	OR12_2 = a_b_e_i | cn_dn_en_in | P31_i;
   assign 	OR12_3 = P31_i | P22_b_c_eeqi | P13_d_e_i;
   assign 	OR12_4 = P22_a_c_eeqi | P13_en;
   assign 	OR12_5 = P13_en | cn_dn_en_in | an_bn_en_in;
   assign 	OR12_6 = P22_an_cn_eeqi | P13_in;
   assign 	OR12_7 = P13_d_e_i | P22_bn_cn_eeqi;
   
   assign 	A = a ^ (OR12_7 | OR12_1 | OR12_2);
   assign 	B = b ^ (OR12_2 | OR12_3 | OR12_4);
   assign 	C = c ^ (OR12_1 | OR12_3 | OR12_5);
   assign 	D = d ^ (OR12_2 | OR12_4 | OR12_7);
   assign 	E = e ^ (OR12_5 | OR12_6 | OR12_7);
   
   // ******************************************************************************
   // Figure 13 - Decoder: 3B/4B
   // ******************************************************************************
   
   // K28 with positive disp into fghi - .1, .2, .5, and .6 specal cases
   assign 	K28p = ! (c | d | e | i) ;
   
   assign 	F = (j & !f & (h | !g | K28p)) | (f & !j & (!h | g | !K28p)) | (K28p & g & h) | (!K28p & !g & !h) ;
   
   assign 	G = (j & !f & (h | !g | !K28p)) | (f & !j & (!h | g |K28p)) | (!K28p & g & h) | (K28p & !g & !h) ;
   
   assign 	H = ((j ^ h) & ! ((!f & g & !h & j & !K28p) | (!f & g & h & !j & K28p) | 
				  (f & !g & !h & j & !K28p) | (f & !g & h & !j & K28p))) | (!f & g & h & j) | (f & !g & !h & !j) ;

   // ******************************************************************************
   // Registered 8B output
   // ******************************************************************************

   always @(posedge RBYTECLK or negedge reset )
     if (!reset)
       begin
	  K_out <= 0; ebi[7:0] <= 8'b0; 
       end
     else 
       begin
	  K_out <= K; ebi[7:0] <= { H, G, F, E, D, C, B, A } ;
       end
   
   // ******************************************************************************
   // Disparity 
   // ******************************************************************************

   wire heqj, fghjP13, fghjP31, fghj22;
   
   wire DISPARITY6p, DISPARITY6n, DISPARITY4p, DISPARITY4n;
   
   wire DISPARITY6b, DISPARITY6a2, DISPARITY6a0;
   
   assign 	feqg = (f & g) | (!f & !g); 
   assign 	heqj = (h & j) | (!h & !j);
   
   assign 	fghjP13 = ( !feqg & !h & !j) | ( !heqj & !f & !g) ;
   assign 	fghjP31 = ( (!feqg) & h & j) | ( !heqj & f & g) ;
   assign 	fghj22 = (f & g & !h & !j) | (!f & !g & h & j) | ( !feqg & !heqj) ;
   
   assign 	DISPARITY6p = (P31 & (e | i)) | (P22 & e & i) ;   
   assign 	DISPARITY6n = (P13 & ! (e & i)) | (P22 & !e & !i);
   
   assign 	DISPARITY4p = fghjP31 ;
   assign 	DISPARITY4n = fghjP13 ;
  
   assign 	DISPARITY6a  = P31 | (P22 & disparity); // pos disp if P22 and was pos, or P31.
   assign 	DISPARITY6a2 = P31 & disparity;         // disp is ++ after 4 bts
   assign 	DISPARITY6a0 = P13 & ! disparity;       // -- disp after 4 bts
   
   assign 	DISPARITY6b = (e & i & ! DISPARITY6a0) | (DISPARITY6a & (e | i)) | DISPARITY6a2;
   
   
   // ******************************************************************************
   // Disparity errors
   // ******************************************************************************
   
   wire 	derr1,derr2,derr3,derr4,derr5,derr6,derr7,derr8;
   
   assign derr1 = (disparity & DISPARITY6p) | (DISPARITY6n & !disparity);
   assign derr2 = (disparity & !DISPARITY6n & f & g);
   assign derr3 = (disparity & a & b & c);
   assign derr4 = (disparity & !DISPARITY6n & DISPARITY4p);
   assign derr5 = (!disparity & !DISPARITY6p & !f & !g);
   assign derr6 = (!disparity & !a & !b & !c);
   assign derr7 = (!disparity & !DISPARITY6p & DISPARITY4n);
   assign derr8 = (DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n);
   
   // ******************************************************************************
   // Register disparity and disparity_err output
   // ******************************************************************************

   reg derr12, derr34, derr56, derr78;

   always @(posedge RBYTECLK or negedge reset )
     if (!reset)
       begin
          disparity <= 1'b0;
          derr12 <= 1;
          derr34 <= 1;
          derr56 <= 1;
          derr78 <= 1;
       end
     else
       begin
	  disparity <= fghjP31 | (DISPARITY6b & fghj22) ;

          derr12 <= derr1 | derr2;
          derr34 <= derr3 | derr4;
          derr56 <= derr5 | derr6;
          derr78 <= derr7 | derr8;
       end

   assign disparity_err = derr12|derr34|derr56|derr78;

   // ******************************************************************************
   // Coding errors as defined in patent - page 447
   // ******************************************************************************

   wire cerr1, cerr2, cerr3, cerr4, cerr5, cerr6, cerr7, cerr8, cerr9;
   
   assign cerr1 = (a &  b &  c &  d) | (!a & !b & !c & !d);
   assign cerr2 = (P13 & !e & !i);
   assign cerr3 = (P31 & e & i);
   assign cerr4 = (f & g & h & j) | (!f & !g & !h & !j);
   assign cerr5 = (e & i & f & g & h) | (!e & !i & !f & !g & !h);
   assign cerr6 = (e & !i & g & h & j) | (!e & i & !g & !h & !j);
   assign cerr7 = (((e & i & !g & !h & !j) | (!e & !i & g & h & j)) & !((c & d & e) | (!c & !d & !e)));
   assign cerr8 = (!P31 & e & !i & !g & !h & !j);
   assign cerr9 = (!P13 & !e & i & g & h & j);

   reg 	  cerr;
   
   always @(posedge RBYTECLK or negedge reset )
     if (!reset)
       cerr <= 0;
     else
       cerr <= cerr1|cerr2|cerr3|cerr4|cerr5|cerr6|cerr7|cerr8|cerr9;
   
   // ******************************************************************************
   // Disparity coding errors curtosy of http://asics.chuckbenz.com/decode.v
   // ******************************************************************************
   
   wire   zerr1, zerr2, zerr3;
   
   assign zerr1 = (DISPARITY6p & DISPARITY4p) | (DISPARITY6n & DISPARITY4n);
   assign zerr2 = (f & g & !h & !j & DISPARITY6p);
   assign zerr3 = (!f & !g & h & j & DISPARITY6n);

   reg 	  zerr;
   
   always @(posedge RBYTECLK or negedge reset )
     if (!reset)
       zerr <= 0;
     else
       zerr <= zerr1|zerr2|zerr3;
   
   // ******************************************************************************
   // Extra coding errors - again from http://asics.chuckbenz.com/decode.v
   // ******************************************************************************
   
   wire   xerr1, xerr2, xerr3, xerr4;

   reg 	  xerr;
   
   assign xerr1 = (a & b & c & !e & !i & ((!f & !g) | fghjP13));
   assign xerr2 =(!a & !b & !c & e & i & ((f & g) | fghjP31));
   assign xerr3 = (c & d & e & i & !f & !g & !h);
   assign xerr4 = (!c & !d & !e & !i & f & g & h);

   always @(posedge RBYTECLK or negedge reset  )
     if (!reset)
       xerr <= 0;
     else
       xerr <= xerr1|xerr2|xerr3|xerr4;
   
   // ******************************************************************************
   // Registered Coding error output
   // ******************************************************************************
   
   always @(posedge RBYTECLK or negedge reset )
     if (!reset) 
       coding_err <= 1'b1;
     else   
       coding_err <= cerr | zerr | xerr;
   
endmodule



/*
module decode(datain, dispin, dataout, dispout, code_err, disp_err) ;
  input [9:0]   datain ;
  input		dispin ;
  output [8:0]	dataout ;
  output	dispout ;
  output	code_err ;
  output	disp_err ;

  wire ai = datain[0] ;
  wire bi = datain[1] ;
  wire ci = datain[2] ;
  wire di = datain[3] ;
  wire ei = datain[4] ;
  wire ii = datain[5] ;
  wire fi = datain[6] ;
  wire gi = datain[7] ;
  wire hi = datain[8] ;
  wire ji = datain[9] ;

  wire aeqb = (ai & bi) | (!ai & !bi) ;
  wire ceqd = (ci & di) | (!ci & !di) ;
  wire p22 = (ai & bi & !ci & !di) |
	     (ci & di & !ai & !bi) |
	     ( !aeqb & !ceqd) ;
  wire p13 = ( !aeqb & !ci & !di) |
	     ( !ceqd & !ai & !bi) ;
  wire p31 = ( !aeqb & ci & di) |
	     ( !ceqd & ai & bi) ;

  wire p40 = ai & bi & ci & di ;
  wire p04 = !ai & !bi & !ci & !di ;

  wire disp6a = p31 | (p22 & dispin) ; // pos disp if p22 and was pos, or p31.
   wire disp6a2 = p31 & dispin ;  // disp is ++ after 4 bits
   wire disp6a0 = p13 & ! dispin ; // -- disp after 4 bits
    
  wire disp6b = (((ei & ii & ! disp6a0) | (disp6a & (ei | ii)) | disp6a2 |
		  (ei & ii & di)) & (ei | ii | di)) ;

  // The 5B/6B decoding special cases where ABCDE != abcde

  wire p22bceeqi = p22 & bi & ci & (ei == ii) ;
  wire p22bncneeqi = p22 & !bi & !ci & (ei == ii) ;
  wire p13in = p13 & !ii ;
  wire p31i = p31 & ii ;
  wire p13dei = p13 & di & ei & ii ;
  wire p22aceeqi = p22 & ai & ci & (ei == ii) ;
  wire p22ancneeqi = p22 & !ai & !ci & (ei == ii) ;
  wire p13en = p13 & !ei ;
  wire anbnenin = !ai & !bi & !ei & !ii ;
  wire abei = ai & bi & ei & ii ;
  wire cdei = ci & di & ei & ii ;
  wire cndnenin = !ci & !di & !ei & !ii ;

  // non-zero disparity cases:
  wire p22enin = p22 & !ei & !ii ;
  wire p22ei = p22 & ei & ii ;
  //wire p13in = p12 & !ii ;
  //wire p31i = p31 & ii ;
  wire p31dnenin = p31 & !di & !ei & !ii ;
  //wire p13dei = p13 & di & ei & ii ;
  wire p31e = p31 & ei ;

  wire compa = p22bncneeqi | p31i | p13dei | p22ancneeqi | 
		p13en | abei | cndnenin ;
  wire compb = p22bceeqi | p31i | p13dei | p22aceeqi | 
		p13en | abei | cndnenin ;
  wire compc = p22bceeqi | p31i | p13dei | p22ancneeqi | 
		p13en | anbnenin | cndnenin ;
  wire compd = p22bncneeqi | p31i | p13dei | p22aceeqi |
		p13en | abei | cndnenin ;
  wire compe = p22bncneeqi | p13in | p13dei | p22ancneeqi | 
		p13en | anbnenin | cndnenin ;

  wire ao = ai ^ compa ;
  wire bo = bi ^ compb ;
  wire co = ci ^ compc ;
  wire d_o = di ^ compd ;
  wire eo = ei ^ compe ;

  wire feqg = (fi & gi) | (!fi & !gi) ;
  wire heqj = (hi & ji) | (!hi & !ji) ;
  wire fghj22 = (fi & gi & !hi & !ji) |
		(!fi & !gi & hi & ji) |
		( !feqg & !heqj) ;
  wire fghjp13 = ( !feqg & !hi & !ji) |
		 ( !heqj & !fi & !gi) ;
  wire fghjp31 = ( (!feqg) & hi & ji) |
		 ( !heqj & fi & gi) ;

  wire dispout = (fghjp31 | (disp6b & fghj22) | (hi & ji)) & (hi | ji) ;

  wire ko = ( (ci & di & ei & ii) | ( !ci & !di & !ei & !ii) |
		(p13 & !ei & ii & gi & hi & ji) |
		(p31 & ei & !ii & !gi & !hi & !ji)) ;

  wire alt7 =   (fi & !gi & !hi & // 1000 cases, where disp6b is 1
		 ((dispin & ci & di & !ei & !ii) | ko |
		  (dispin & !ci & di & !ei & !ii))) |
		(!fi & gi & hi & // 0111 cases, where disp6b is 0
		 (( !dispin & !ci & !di & ei & ii) | ko |
		  ( !dispin & ci & !di & ei & ii))) ;

  wire k28 = (ci & di & ei & ii) | ! (ci | di | ei | ii) ;
  // k28 with positive disp into fghi - .1, .2, .5, and .6 special cases
  wire k28p = ! (ci | di | ei | ii) ;
  wire fo = (ji & !fi & (hi | !gi | k28p)) |
	    (fi & !ji & (!hi | gi | !k28p)) |
	    (k28p & gi & hi) |
	    (!k28p & !gi & !hi) ;
  wire go = (ji & !fi & (hi | !gi | !k28p)) |
	    (fi & !ji & (!hi | gi |k28p)) |
	    (!k28p & gi & hi) |
	    (k28p & !gi & !hi) ;
  wire ho = ((ji ^ hi) & ! ((!fi & gi & !hi & ji & !k28p) | (!fi & gi & hi & !ji & k28p) | 
			    (fi & !gi & !hi & ji & !k28p) | (fi & !gi & hi & !ji & k28p))) |
	    (!fi & gi & hi & ji) | (fi & !gi & !hi & !ji) ;

  wire disp6p = (p31 & (ei | ii)) | (p22 & ei & ii) ;
  wire disp6n = (p13 & ! (ei & ii)) | (p22 & !ei & !ii) ;
  wire disp4p = fghjp31 ;
  wire disp4n = fghjp13 ;

  assign code_err = p40 | p04 | (fi & gi & hi & ji) | (!fi & !gi & !hi & !ji) |
		    (p13 & !ei & !ii) | (p31 & ei & ii) | 
		    (ei & ii & fi & gi & hi) | (!ei & !ii & !fi & !gi & !hi) | 
		    (ei & !ii & gi & hi & ji) | (!ei & ii & !gi & !hi & !ji) |
		    (!p31 & ei & !ii & !gi & !hi & !ji) |
		    (!p13 & !ei & ii & gi & hi & ji) |
		    (((ei & ii & !gi & !hi & !ji) | 
		      (!ei & !ii & gi & hi & ji)) &
		     ! ((ci & di & ei) | (!ci & !di & !ei))) |
		    (disp6p & disp4p) | (disp6n & disp4n) |
		    (ai & bi & ci & !ei & !ii & ((!fi & !gi) | fghjp13)) |
		    (!ai & !bi & !ci & ei & ii & ((fi & gi) | fghjp31)) |
		    (fi & gi & !hi & !ji & disp6p) |
		    (!fi & !gi & hi & ji & disp6n) |
		    (ci & di & ei & ii & !fi & !gi & !hi) |
		    (!ci & !di & !ei & !ii & fi & gi & hi) ;

  assign dataout = {ko, ho, go, fo, eo, d_o, co, bo, ao} ;

  // my disp err fires for any legal codes that violate disparity, may fire for illegal codes
   assign disp_err = ((dispin & disp6p) | (disp6n & !dispin) |
		      (dispin & !disp6n & fi & gi) |
		      (dispin & ai & bi & ci) |
		      (dispin & !disp6n & disp4p) |
		      (!dispin & !disp6p & !fi & !gi) |
		      (!dispin & !ai & !bi & !ci) |
		      (!dispin & !disp6p & disp4n) |
		      (disp6p & disp4p) | (disp6n & disp4n)) ;

endmodule
*/

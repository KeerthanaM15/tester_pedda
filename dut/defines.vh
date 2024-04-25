////////////////////////////////////////////////////////////////////////
////*  Copyright (c) 2023 Tessolve Semiconductor Pvt. Ltd.         *////
////*  Author: Prabhu Munisamy, prabhu.munisamy@tessolve.com       *////
////*  Lead: Marmik Soni, marmikbhupendrakumar.soni@tessolve.com   *////
////*  Mentor: Mike Bartley, mike.bartley@tessolve.com             *////
////*  Department: CoE                                             *////
////*  Created on: Friday 11 Aug 2023 08:10:00 IST                 *////
////*  Project: IEEE1149.10 IP Design                              *////
////*  Description: define file for Control Characters             *////
////////////////////////////////////////////////////////////////////////

//CONTROL CHAR DEFINES
`define SOP_CHAR        8'hFB
`define EOP_CHAR        8'hFD
`define IDLE_CHAR       8'hBC
`define ERROR_CHAR      8'hFE
`define XOFF_CHAR       8'h7C
`define XON_CHAR        8'h1C
`define CLEAR_CHAR      8'h5C
`define COMPLIANCE_CHAR 8'hDC
`define BOND_CHAR       8'h9C
`define SCANOUT_STALL   8'h3C
//`define 8'hFC
//`define 8'hF7

//INBOUND COMMAND VALUE DEFINES
`define CONFIG_CMD    8'h01
`define TARGET_CMD    8'h02
`define RESET_CMD     8'h03
`define RAW_CMD       8'h04
`define CH_SELECT_CMD 8'h05
`define SCAN_CMD      8'h06
`define PKT_RESP_CMD  8'b1000_0???

//FOR TESTER PEDDA TX CTRL INBOUND CMD
`define SCAN_GROUP     16'h0100
`define CH_SELECT      16'h0100
`define INBD_CFG_CMD   8'h01
`define INBD_TGT_CMD   8'h02
`define INBD_RST_CMD   8'h03
`define INBD_RAW_CMD   8'h04
`define INBD_CHSEL_CMD 8'h05
`define INBD_SCAN_CMD  8'h06

//OUTBOUND COMMAND VALUE DEFINES
`define CONFIGR_CMD     8'h81  // Config response command without parity
`define TARGETR_CMD     8'h82  // Target response command without parity
`define RESETR_CMD      8'h83  // Reset response command without parity
`define RAWR_CMD        8'h84  // RAW response command without parity
`define CH_SELECTR_CMD  8'h85  // Ch-Select response command without parity
`define SCANR_CMD       8'h86  // Scan response command without parit


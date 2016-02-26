/*****************************************************************************
 * (C) Copyright 2015 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * MODULE:      endec_64b66b_types.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: File containing types used by the endec_64b66b package
 ****************************************************************************/

`ifndef ENDEC_64b66b_TYPES_SVH
`define ENDEC_64b66b_TYPES_SVH

// enum holding the 5 possible block types
typedef enum {
   C_BLOCK=0, S_BLOCK=1, T_BLOCK=2, D_BLOCK=3, E_BLOCK=4
} endec_64b66b_rx_tx_block_type_e;


// enum holding the defined control characters on xgmii interface
typedef enum  byte unsigned {
   I_CONTROL= 8'h07, S_CONTROL=8'hfb, T_CONTROL=8'hfd, E_CONTROL=8'hfe, Q_CONTROL=8'h9c, NON_CONTROL=8'h00
} endec_64b66b_xgmii_control_code_e;


// enum for valid block formats
typedef enum {
   // DDDD/DDDD
   ALL_DATA_FORMAT=0,
   // CCCC/CCCC
   ALL_CONTROL_FORMAT=1,
   // CCCC/ODDD
   CONTROL_ORDSET_FORMAT=2,
   // CCCC/SDDD
   CONTROL_START_FORMAT=3,
   // ODDD/SDDD
   ORDSET_START_FORMAT=4,
   // ODDD/ODDD
   ORDSET_ORDSET_FORMAT=5,
   // SDDD/DDDD
   START_DATA_FORMAT=6,
   // ODDD/CCCC
   ORDSET_CONTROL_FORMAT=7,
   // TCCC/CCCC
   TERMINATE7_FORMAT=8,
   // DTCC/CCCC
   TERMINATE6_FORMAT=9,
   // DDTC/CCCC
   TERMINATE5_FORMAT=10,
   // DDDT/CCCC
   TERMINATE4_FORMAT=11,
   // DDDD/TCCC
   TERMINATE3_FORMAT=12,
   // DDDD/DTCC
   TERMINATE2_FORMAT=13,
   // DDDD/DDTC
   TERMINATE1_FORMAT=14,
   // DDDD/DDDT
   TERMINATE0_FORMAT=15
} endec_64b66b_block_formats_e;


// enum for block type fields
typedef enum byte unsigned {
   BLK_TYPE_0 = 8'h1e,
   BLK_TYPE_1 = 8'h2d,
   BLK_TYPE_2 = 8'h33,
   BLK_TYPE_3 = 8'h66,
   BLK_TYPE_4 = 8'h55,
   BLK_TYPE_5 = 8'h78,
   BLK_TYPE_6 = 8'h4b,
   BLK_TYPE_7 = 8'h87,
   BLK_TYPE_8 = 8'h99,
   BLK_TYPE_9 = 8'haa,
   BLK_TYPE_10= 8'hb4,
   BLK_TYPE_11= 8'hcc,
   BLK_TYPE_12= 8'hd2,
   BLK_TYPE_13= 8'he1,
   BLK_TYPE_14= 8'hff
} endec_64b66b_block_type_field_e;


// by default it's int
// type used to name the states of the transmitting state machine
typedef enum {
   TX_INIT=0, TX_C=1, TX_D=2, TX_T=3, TX_E=4
} endec_64b66b_transmit_sm_states_e;


// unpacked 7bit array
// used as return type of function
typedef bit[6:0] bits7_unpacked_arr [];


// type used to name the states of the receiving state machine
typedef enum {
   RX_INIT=0, RX_C=1, RX_D=2, RX_T=3, RX_E=4
} endec_64b66b_receive_sm_states_e;


`endif
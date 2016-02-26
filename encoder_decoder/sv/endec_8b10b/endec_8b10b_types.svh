/******************************************************************************
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
 * MODULE:      endec_8b10b_types.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains type declarations for
 *              the endec_8b10b package
 *****************************************************************************/

`ifndef ENDEC_8b10b_TYPES_SVH
`define ENDEC_8b10b_TYPES_SVH

//serves as input of the encoder and output of the decoder
typedef struct  {
   // 8 bit value input for encoding
   // or output of decoding
   bit [7:0] enc_dec_8b_val;
   // field indicating if it's data or control symbol
   bit is_k_symbol;
   //used to register decoding errors
   // 0 - no error
   // 1 - disparity error
   // 2 - symbol error
   bit [1:0] decode_err;
} endec_8b10b_enc_in_dec_out_s;

//typedef for the special symbols involved in this coding/decoding method
//in 8bit representation
typedef enum bit[7:0] {
   K_28_0_8B = 8'h1C,
   K_28_1_8B = 8'h3C,
   K_28_2_8B = 8'h5C,
   K_28_3_8B = 8'h7C,
   K_28_4_8B = 8'h9C,
   K_28_5_8B = 8'hBC,
   K_28_6_8B = 8'hDC,
   K_28_7_8B = 8'hFC,
   K_23_7_8B = 8'hF7,
   K_27_7_8B = 8'hFB,
   K_29_7_8B = 8'hFD,
   K_30_7_8B = 8'hFE
} endec_8b10b_k_8b_e;

//6bit encoded representation of the 5msb bits of the 8bit input data (control symbols)
typedef enum bit[5:0] {
   K_28_6B_N = 6'b00_1111,
   K_28_6B_P = 6'b11_0000,
   K_23_6B_N = 6'b11_1010,
   K_23_6B_P = 6'b00_0101,
   K_27_6B_N = 6'b11_0110,
   K_27_6B_P = 6'b00_1001,
   K_29_6B_N = 6'b10_1110,
   K_29_6B_P = 6'b01_0001,
   K_30_6B_N = 6'b01_1110,
   K_30_6B_P = 6'b10_0001
} endec_8b10b_k_6b_e;

//4bit encoded representation of the 3 msb bits of 8bit input data (control symbols)
//these are used if current value of running disparity is negative
typedef enum bit[3:0] {
   K_X_0_4B_N = 4'b1011,
   K_X_1_4B_N = 4'b0110,
   K_X_2_4B_N = 4'b1010,
   K_X_3_4B_N = 4'b1100,
   K_X_4_4B_N = 4'b1101,
   K_X_5_4B_N = 4'b0101,
   K_X_6_4B_N = 4'b1001,
   K_X_7_4B_N = 4'b0111
} endec_8b10b_k_4b_n_e;

//4bit encoded representation of the 3 msb bits of 8bit input data (control symbols)
//these are used if current value of running disparity is positive
typedef enum bit[3:0] {
   K_X_0_4B_P  = 4'b0100,
   K_X_1_4B_P  = 4'b1001,
   K_X_2_4B_P  = 4'b0101,
   K_X_3_4B_P  = 4'b0011,
   K_X_4_4B_P  = 4'b0010,
   K_X_5_4B_P  = 4'b1010,
   K_X_6_4B_P  = 4'b0110,
   K_X_7_4B_P  = 4'b1000
} endec_8b10b_k_4b_p_e;

//10bit encoded representation of control symbols
typedef enum bit[9:0] {
   K_28_0_10B_N =  10'b00_1111_0100,
   K_28_0_10B_P =  10'b11_0000_1011,
   K_28_1_10B_N =  10'b00_1111_1001,
   K_28_1_10B_P =  10'b11_0000_0110,
   K_28_2_10B_N =  10'b00_1111_0101,
   K_28_2_10B_P =  10'b11_0000_1010,
   K_28_3_10B_N =  10'b00_1111_0011,
   K_28_3_10B_P =  10'b11_0000_1100,
   K_28_4_10B_N =  10'b00_1111_0010,
   K_28_4_10B_P =  10'b11_0000_1101,
   K_28_5_10B_N =  10'b00_1111_1010,
   K_28_5_10B_P =  10'b11_0000_0101,
   K_28_6_10B_N =  10'b00_1111_0110,
   K_28_6_10B_P =  10'b11_0000_1001,
   K_28_7_10B_N =  10'b00_1111_1000,
   K_28_7_10B_P =  10'b11_0000_0111,
   K_23_7_10B_N =  10'b11_1010_1000,
   K_23_7_10B_P =  10'b00_0101_0111,
   K_27_7_10B_N =  10'b11_0110_1000,
   K_27_7_10B_P =  10'b00_1001_0111,
   K_29_7_10B_N =  10'b10_1110_1000,
   K_29_7_10B_P =  10'b01_0001_0111,
   K_30_7_10B_N =  10'b01_1110_1000,
   K_30_7_10B_P =  10'b10_0001_0111
} endec_8b10b_k_10b_e;

//6bit encoded representation of the 5 lsb bits of 8bit input data
typedef enum bit[5:0] {
   D_00_6B_N = 6'b10_0111,
   D_00_6B_P = 6'b01_1000,
   D_01_6B_N = 6'b01_1101,
   D_01_6B_P = 6'b10_0010,
   D_02_6B_N = 6'b10_1101,
   D_02_6B_P = 6'b01_0010,
   D_03_6B   = 6'b11_0001,
   D_04_6B_N = 6'b11_0101,
   D_04_6B_P = 6'b00_1010,
   D_05_6B   = 6'b10_1001,
   D_06_6B   = 6'b01_1001,
   D_07_6B_N = 6'b11_1000,
   D_07_6B_P = 6'b00_0111,
   D_08_6B_N = 6'b11_1001,
   D_08_6B_P = 6'b00_0110,
   D_09_6B   = 6'b10_0101,
   D_10_6B   = 6'b01_0101,
   D_11_6B   = 6'b11_0100,
   D_12_6B   = 6'b00_1101,
   D_13_6B   = 6'b10_1100,
   D_14_6B   = 6'b01_1100,
   D_15_6B_N = 6'b01_0111,
   D_15_6B_P = 6'b10_1000,
   D_16_6B_N = 6'b01_1011,
   D_16_6B_P = 6'b10_0100,
   D_17_6B   = 6'b10_0011,
   D_18_6B   = 6'b01_0011,
   D_19_6B   = 6'b11_0010,
   D_20_6B   = 6'b00_1011,
   D_21_6B   = 6'b10_1010,
   D_22_6B   = 6'b01_1010,
   D_23_6B_N = 6'b11_1010,
   D_23_6B_P = 6'b00_0101,
   D_24_6B_N = 6'b11_0011,
   D_24_6B_P = 6'b00_1100,
   D_25_6B   = 6'b10_0110,
   D_26_6B   = 6'b01_0110,
   D_27_6B_N = 6'b11_0110,
   D_27_6B_P = 6'b00_1001,
   D_28_6B   = 6'b00_1110,
   D_29_6B_N = 6'b10_1110,
   D_29_6B_P = 6'b01_0001,
   D_30_6B_N = 6'b01_1110,
   D_30_6B_P = 6'b10_0001,
   D_31_6B_N = 6'b10_1011,
   D_31_6B_P = 6'b01_0100
} endec_8b10b_d_6b_e;

//4bit encoded representation of the 3 msb bits of 8bit input data
typedef enum bit[3:0] {
   D_X_0_4B_N  = 4'b1011,
   D_X_0_4B_P  = 4'b0100,
   D_X_1_4B    = 4'b1001,
   D_X_2_4B    = 4'b0101,
   D_X_3_4B_N  = 4'b1100,
   D_X_3_4B_P  = 4'b0011,
   D_X_4_4B_N  = 4'b1101,
   D_X_4_4B_P  = 4'b0010,
   D_X_5_4B    = 4'b1010,
   D_X_6_4B    = 4'b0110,
   D_X_P7_4B_N = 4'b1110,
   D_X_P7_4B_P = 4'b0001,
   D_X_A7_4B_N = 4'b0111,
   D_X_A7_4B_P = 4'b1000
} endec_8b10b_d_4b_e;

`endif//ENDEC_8b10b_TYPES_SVH
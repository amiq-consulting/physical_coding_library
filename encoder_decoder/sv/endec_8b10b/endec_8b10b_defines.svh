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
 * MODULE:      endec_8b10b_defines.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains defines used by endec_8b10b package
 *****************************************************************************/

`ifndef ENDEC_8b10b_DEFINES_SVH
`define ENDEC_8b10b_DEFINES_SVH

//add defines if any are needed

//Defines beneath are not to be changed

//each bit holds information for 5b6b encoded values from 0 to 31
//if bit is 1 means the corresponding value has two
//encodings, one for each running disparity
//zero means single, neutral encoding
`define ENDEC_5B6B_SYMBOL_HAS_DOUBLE_ENCODING  32'b11101001100000011000000110010111

//each bit holds information for 3b4b encoded values from  0 to 7, the additional bit is for
//value 7 which has two different encodings(primary and alternative)
//if bit is 1 means the corresponding value has two
//encodings, one for each running disparity
//zero means single, neutral encoding
`define ENDEC_3B4B_SYMBOL_HAS_DOUBLE_ENCODING  9'b110011001


`endif//ENDEC_8b10b_DEFINES_SVH

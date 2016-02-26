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
 * MODULE:      endec_64b66b_defines.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: Defines file for the endec_64b66b package
 *******************************************************************************/


`ifndef ENDEC_64b66b_DEFINES_SVH
`define ENDEC_64b66b_DEFINES_SVH

   // default error block output
   `define T_EBLOCK_T  {2'b10,8'hfe,{8{7'h1e}}}

   // used as output from decoding logic  in case of error
   `define R_EBLOCK_T  {4'hf, {4{8'hfe}}, 4'hf, {4{8'hfe}}}

`endif//ENDEC_64b66b_DEFINES_SVH



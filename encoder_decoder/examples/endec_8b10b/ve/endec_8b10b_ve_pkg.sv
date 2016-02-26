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
 * MODULE:      endec_8b10b_ve_pkg.sv
 * PROJECT:     endec_8b10b
 *
 *
 * Description: Package containing the verification environment
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_PKG_SV
`define ENDEC_8b10b_VE_PKG_SV

package endec_8b10b_ve_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"
   import endec_8b10b_pkg::*;

`include "endec_8b10b_ve_encoder_seq_item.svh"
`include "endec_8b10b_ve_decoder_seq_item.svh"

`include "endec_8b10b_ve_encoder_sequencer.svh"
`include "endec_8b10b_ve_encoder_driver.svh"
`include "endec_8b10b_ve_decoder_sequencer.svh"
`include "endec_8b10b_ve_decoder_driver.svh"

`include "endec_8b10b_ve_seq_lib.svh"
`include "endec_8b10b_ve_encoder_agent.svh"
`include "endec_8b10b_ve_decoder_agent.svh"

`include "endec_8b10b_ve_scb.svh"
`include "endec_8b10b_ve_env.svh"
endpackage

`endif//ENDEC_8b10b_VE_PKG_SV

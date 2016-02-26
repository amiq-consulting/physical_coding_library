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
 * MODULE:      endec_64b66b_ve_pkg.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: Package containing the implementation of verification environment
 *******************************************************************************/

`ifndef ENDEC_64b66b_VE_PKG_SV
`define ENDEC_64b66b_VE_PKG_SV

`include "uvm_macros.svh"
`include "endec_64b66b_pkg.sv"

package endec_64b66b_ve_pkg;

   import uvm_pkg::*;
   import endec_64b66b_pkg::*;

`include "endec_64b66b_ve_seq_item.svh"
`include "endec_64b66b_ve_sequencer.svh"
`include "endec_64b66b_ve_drv.svh"
`include "endec_64b66b_ve_agent.svh"
`include "endec_64b66b_ve_scoreboard.svh"
`include "endec_64b66b_ve_sequence_lib.svh"
`include "endec_64b66b_ve_env.svh"

endpackage

`endif

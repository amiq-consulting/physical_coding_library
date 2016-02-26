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
 * MODULE:      endec_8b10b_pkg.sv
 * PROJECT:     endec_8b10b
 *
 *
 * Description: Package containing the implementation of endec_8b10b 
 *              encoder/decoder
 *****************************************************************************/

`ifndef ENDEC_8b10b_PKG_SV
`define ENDEC_8b10b_PKG_SV

package endec_8b10b_pkg;

   import uvm_pkg::*;
`include "uvm_macros.svh"

`include "endec_8b10b_defines.svh"
`include "endec_8b10b_types.svh"

`include "endec_8b10b_cov_item.svh"
`include "endec_8b10b_coverage.svh"

`include "endec_8b10b_mappings.svh"
`include "endec_8b10b_encoder.svh"
`include "endec_8b10b_decoder.svh"

endpackage

`endif//ENDEC_8b10b_PKG_SV
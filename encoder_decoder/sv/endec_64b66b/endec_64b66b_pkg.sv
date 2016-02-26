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
 * MODULE:      endec_64b66b_pkg.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the package file
 *******************************************************************************/


`ifndef ENDEC_64b66b_PKG_SV
`define ENDEC_64b66b_PKG_SV

`include "uvm_macros.svh"

package endec_64b66b_pkg;
   import uvm_pkg::*;


`include "endec_64b66b_defines.svh"
`include "endec_64b66b_types.svh"
`include "endec_64b66b_cov_items.svh"
`include "endec_64b66b_encoder_cov.svh"
`include "endec_64b66b_encoder.svh"
`include "endec_64b66b_decoder_cov.svh"
`include "endec_64b66b_decoder.svh"

endpackage

`endif
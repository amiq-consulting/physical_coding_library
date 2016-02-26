
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
 * MODULE:      endec_64b66b_tests_pkg.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: Package containing the tests library
 *******************************************************************************/

`ifndef ENDEC_64b66b_TESTS_PKG_SV
`define ENDEC_64b66b_TESTS_PKG_SV

package endec_64b66b_tests_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"

   import endec_64b66b_ve_pkg::*;

`include "endec_64b66b_tests_base_test.svh"
`include "endec_64b66b_tests_legal_seq_test.svh"
`include "endec_64b66b_tests_rand_seq_test.svh"

endpackage

`endif
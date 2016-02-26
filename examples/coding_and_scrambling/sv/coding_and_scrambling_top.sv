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
 * MODULE:      coding_and_scrambling_top.sv
 * PROJECT:     physical_coding_algorithms
 *
 *
 * Description: This file contains the top module used for starting the test
 *******************************************************************************/

`ifndef CODING_AND_SCRAMBLING_TOP_SV
`define CODING_AND_SCRAMBLING_TOP_SV


`include "uvm_macros.svh"

import uvm_pkg::*;
import endec_64b66b_pkg::*;
import endec_64b66b_ve_pkg::*;
import endec_64b66b_tests_pkg::*;
import scrambler_descrambler_pkg::*;

`include "endec_64b66b_driver_with_scrambler.svh"

`include "endec_64b66b_with_scrambler_test.sv"

module coding_and_scrambling_top;

   initial begin
      run_test("");
   end

endmodule

`endif

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
 * MODULE:      endec_8b10b_top.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the top module used for starting the test
 *******************************************************************************/

`ifndef ENDEC_8b10b_TOP_SVH
`define ENDEC_8b10b_TOP_SVH

`timescale 1ns/1ps

import uvm_pkg::*;
import endec_8b10b_tests_pkg::*;

module endec_8b10b_top;

   initial begin
      run_test("");
   end

endmodule

`endif//ENDEC_8b10b_TOP_SVH

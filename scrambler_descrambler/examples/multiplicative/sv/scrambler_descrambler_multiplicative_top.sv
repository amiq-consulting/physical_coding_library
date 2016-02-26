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
 * NAME:        scrambler_descrambler_multiplicative_top.sv
 * PROJECT:     scrambler_descrambler
 * Description: This file contains the declaration of the verilog module used
 *              in the multiplicative example of the scrambler_descrambler pkg.
 *******************************************************************************/


`ifndef SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TOP_SV
`define SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TOP_SV


`include "scrambler_descrambler_multiplicative_test.sv"

module scrambler_descrambler_multiplicative_top;

   initial begin
      run_test("scrambler_descrambler_multiplicative_test");
   end

endmodule


`endif
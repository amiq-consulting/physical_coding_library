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
 * MODULE:      scrambler_descrambler_multiplicative_test.sv
 * PROJECT:     scrambler_descrambler
 *
 *
 * Description: This is the test file for multiplicative scrambler/descrambler
 *******************************************************************************/


`ifndef SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST_SV
`define SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST_SV


import uvm_pkg::*;
`include "uvm_macros.svh"

import scrambler_descrambler_pkg::*;


/* Test class
 *
 */
class scrambler_descrambler_multiplicative_test extends uvm_test;
   `uvm_component_utils(scrambler_descrambler_multiplicative_test)


   // convenience parameter holding the order of the polynomial
   parameter ORDER = 64;


   // scrambler instance
   scrambler_multiplicative#(ORDER, 'h8001000000000000) m_mult_scrambler;
   // descrambler instance
   descrambler_multiplicative#(ORDER, 'h8001000000000000) m_mult_descrambler;

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(input string name, input uvm_component parent);
      // call super.new()
      super.new(name, parent);
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // the polynomial is x^63 + x^48
      m_mult_scrambler = scrambler_multiplicative #(ORDER, 'h8001000000000000)::type_id::create(
         "m_mult_scrambler",
         this
      );
      m_mult_descrambler = descrambler_multiplicative #(ORDER, 'h8001000000000000)::type_id::create(
         "m_mult_descrambler",
         this
      );
   endfunction


   /* UVM run_phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);
      // fields used as input or for holding intermediate results
      bit[ORDER-1:0] scrambler_in;
      bit[ORDER-1:0] scrambler_out;
      bit[ORDER-1:0] descrambler_out;


      // bit-stream input/output from scrambler/descrambler
      bs_t bs_input_0;
      bs_t bs_output_0;
      bs_t bs_input_1;
      bs_t bs_output_1;

      //determines number of iteration
      int num_of_iterations;
      void'(std::randomize(num_of_iterations) with {
            (num_of_iterations > 10) && (num_of_iterations < 100);
         });


      for (int iter = 0; iter < num_of_iterations; iter++) begin
         // randomize scrambler input
         if (!std::randomize(scrambler_in)) begin
            `uvm_error("SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST", "Randomizing failed.")
         end


         bs_input_0 = {>>{scrambler_in}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST",
            $sformatf("Scrambler 0 input compact  %x",scrambler_in),
            UVM_HIGH
         )


         bs_output_0 = m_mult_scrambler.scramble(bs_input_0);
         scrambler_out = {>>{bs_output_0}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST",
            $sformatf("Scrambler 0 output %x", scrambler_out),
            UVM_HIGH
         )


         bs_input_1 = {>>{scrambler_out}};
         bs_output_1 = m_mult_descrambler.descramble(bs_input_1);
         descrambler_out = {>>{bs_output_1}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST",
            $sformatf("Descrambler output %x\n\n\n",descrambler_out),
            UVM_HIGH
         )


         // perform scoreboarding between scrambler input and descrambler output
         assert (scrambler_in == descrambler_out) else
            `uvm_error(
               "SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST",
               $sformatf("\nDifference between scrambler input value %x\nand descrambler output value             %x",
                  scrambler_in, descrambler_out)
            )
      end
   endtask

endclass


`endif//SCRAMBLER_DESCRAMBLER_MULTIPLICATIVE_TEST_SV
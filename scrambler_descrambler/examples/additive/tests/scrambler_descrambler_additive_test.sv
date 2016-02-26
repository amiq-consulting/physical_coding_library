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
 * MODULE:      scrambler_descrambler_additive_test.sv
 * PROJECT:     scrambler_descrambler
 *
 *
 * Description: This is the package file
 *******************************************************************************/


`ifndef SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST_SV
`define SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST_SV


import uvm_pkg::*;
`include "uvm_macros.svh"

import scrambler_descrambler_pkg::*;


/* Test class
 *
 */
class scrambler_descrambler_additive_test extends uvm_test;
   `uvm_component_utils(scrambler_descrambler_additive_test)


   // convenience parameter holding the order of the polynomial
   parameter ORDER = 64;


   // the scrambler and descrambler are actually the same
   scrambler_descrambler_additive#(ORDER, 'h8001000000000000) m_add_scrambler;
   // descrambler instance
   scrambler_descrambler_additive#(ORDER, 'h8001000000000000) m_add_descrambler;


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

      m_add_scrambler   = scrambler_descrambler_additive #(ORDER, 'h8001000000000000)::type_id::create(
         "m_add_scrambler",
         this
      );
      m_add_descrambler = scrambler_descrambler_additive #(ORDER, 'h8001000000000000)::type_id::create(
         "m_add_descrambler",
         this
      );

      // load same initial values in both scrambler and descrambler
      m_add_scrambler.load_lfsr('h2a);
      m_add_descrambler.load_lfsr('h2a);
   endfunction


   /* UVM run_phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);
      // fields used as input or for holding intermediate results
      bit[ORDER-1:0] scrambler_input;
      bit[ORDER-1:0] scrambler_output;
      bit[ORDER-1:0] descrambler_output;


      // bit-stream input/output from scrambler/descrambler
      bs_t bs_input_0;
      bs_t bs_output_0;
      bs_t bs_input_1;
      bs_t bs_output_1;

      //determines number of iteration
      int num_of_iterations;
      void'(std::randomize(num_of_iterations) with {
            (num_of_iterations > 20) && (num_of_iterations < 100);
         });

      for (int iter = 0; iter < num_of_iterations; iter++) begin
         // randomize scrambler input
         if (!std::randomize(scrambler_input)) begin
            `uvm_error("SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST", "Randomizing failed.")
         end


         bs_input_0 = {>>{scrambler_input}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST",
            $sformatf("Scrambler 0 input compact  %x",scrambler_input),
            UVM_HIGH
         )


         bs_output_0 = m_add_scrambler.scramble(bs_input_0);
         scrambler_output = {>>{bs_output_0}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST",
            $sformatf("Scrambler 0 output compact %x", scrambler_output),
            UVM_HIGH
         )


         bs_input_1 = {>>{scrambler_output}};
         bs_output_1 = m_add_descrambler.descramble(bs_input_1);
         descrambler_output = {>>{bs_output_1}};
         `uvm_info(
            "SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST",
            $sformatf("Descrambler output compact %x\n\n\n",descrambler_output),
            UVM_HIGH
         )


         // perform scoreboarding between scrambler input and descrambler output
         assert (scrambler_input == descrambler_output) else
            `uvm_error(
               "SCRAMBLER_DESCRAMBLER_ADDITIVE_TEST",
               $sformatf("\nDifference between scrambler input value %x\nand descrambler output value             %x",
                  scrambler_input,
                  descrambler_output
               )
            )
      end
   endtask

endclass


`endif
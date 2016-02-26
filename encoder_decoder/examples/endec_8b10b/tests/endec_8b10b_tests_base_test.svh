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
 * MODULE:      endec_8b10b_tests_base_test.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the base test
 *****************************************************************************/

`ifndef ENDEC_8b10b_TESTS_BASE_TEST_SVH
`define ENDEC_8b10b_TESTS_BASE_TEST_SVH

/* Base test class
 */
class endec_8b10b_tests_base_test extends uvm_test;
   `uvm_component_utils(endec_8b10b_tests_base_test)


   // Verification environment
   endec_8b10b_ve_env m_env;

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(input string name, input uvm_component parent);
      super.new(name, parent);
   endfunction

   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_env = endec_8b10b_ve_env::type_id::create("m_env", this);     
   endfunction

endclass

`endif//ENDEC_8b10b_TESTS_BASE_TEST_SVH

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
 * MODULE:      endec_8b10b_tests_encoder_decoder_test.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the test with random symbols
 ***************************************************************************/

`ifndef ENDEC_8b10b_TESTS_ENCODER_DECODER_TEST_SVH
`define ENDEC_8b10b_TESTS_ENCODER_DECODER_TEST_SVH

/* Test class
 */
class endec_8b10b_tests_encoder_decoder_test extends endec_8b10b_tests_base_test;
   `uvm_component_utils(endec_8b10b_tests_encoder_decoder_test)

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
   endfunction

   /* UVM run phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);

      endec_8b10b_ve_encoder_seq en_seq = endec_8b10b_ve_encoder_seq::type_id::create(
         "en_seq", m_env.m_enc_agent.m_sequencer_h
      );
      endec_8b10b_ve_decoder_response_seq de_seq = endec_8b10b_ve_decoder_response_seq::type_id::create(
         "de_seq", m_env.m_dec_agent.m_sequencer_h
      );

      phase.raise_objection(this);

      assert(en_seq.randomize() with {m_nof_items == 1500;});

      fork:start_sequencers
         begin
            en_seq.start(m_env.m_enc_agent.m_sequencer_h);
         end
         begin
            de_seq.start(m_env.m_dec_agent.m_sequencer_h);
         end
      join_any:start_sequencers

      phase.drop_objection(this);

   endtask

endclass

`endif//ENDEC_8b10b_TESTS_ENCODER_DECODER_TEST_SVH

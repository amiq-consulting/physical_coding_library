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
 * MODULE:      endec_8b10b_ve_decoder_sequencer.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This is the implementation file of 8b10b_decoder sequencer
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_DECODER_SEQUENCER_SVH
`define ENDEC_8b10b_VE_DECODER_SEQUENCER_SVH

/* Decoder sequencer
 */
class endec_8b10b_ve_decoder_sequencer extends uvm_sequencer #(endec_8b10b_ve_decoder_seq_item);
   `uvm_component_utils(endec_8b10b_ve_decoder_sequencer)

   // Events used for synchronization
   event start_dec_resp_seq;

   // Events used for synchronization
   event dec_resp_seq_done;

   // Blocking put import
   uvm_blocking_put_imp#(endec_8b10b_ve_decoder_seq_item, endec_8b10b_ve_decoder_sequencer) m_port;

   // Sequence item used to be sent
   endec_8b10b_ve_decoder_seq_item m_it;

   /* Constructor
    * @param name : instance name
    * @param parent : parent component
    */
   function new (input string name, input uvm_component parent);
      super.new(name, parent);
      m_port = new("m_port", this);
   endfunction

   /* Put task implementation
    * @param t : sequence item to be sent
    */
   virtual task put(input endec_8b10b_ve_decoder_seq_item t);
      m_it = t;
      -> start_dec_resp_seq;
      @(dec_resp_seq_done);
   endtask

endclass

`endif//ENDEC_8b10b_VE_DECODER_SEQUENCER_SVH

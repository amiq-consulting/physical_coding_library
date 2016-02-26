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
 * MODULE:      endec_8b10b_ve_seq_lib.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the sequence library.
 *****************************************************************************/
`ifndef ENDEC_8b10b_VE_SEQ_LIB_SVH
`define ENDEC_8b10b_VE_SEQ_LIB_SVH

/* Decoder response sequence
 */
class endec_8b10b_ve_decoder_response_seq extends uvm_sequence #(endec_8b10b_ve_decoder_seq_item);
   `uvm_object_utils(endec_8b10b_ve_decoder_response_seq)
   `uvm_declare_p_sequencer(endec_8b10b_ve_decoder_sequencer)

   // Sequence item
   endec_8b10b_ve_decoder_seq_item m_seq_item;

   /* Default constructor
    * @param name : instance name
    */
   function new(input string name = "");
      super.new(name);
   endfunction

   /* body() task implementation
    */
   virtual task body();
      forever begin
         @(p_sequencer.start_dec_resp_seq);

         m_seq_item = endec_8b10b_ve_decoder_seq_item::type_id::create("m_seq_item",,get_full_name());
         start_item(m_seq_item);
         m_seq_item.m_encoded_symbol = p_sequencer.m_it.m_encoded_symbol;
         finish_item(m_seq_item);
         -> p_sequencer.dec_resp_seq_done;
      end
   endtask
endclass

/* Basic encoder sequence
 */
class endec_8b10b_ve_encoder_seq extends uvm_sequence #(endec_8b10b_ve_encoder_seq_item);
   `uvm_object_utils(endec_8b10b_ve_encoder_seq)

   // Number of items in sequence
   rand int m_nof_items;

   // Sequence item
   endec_8b10b_ve_encoder_seq_item m_seq_item;

   /* Default constructor
    * @param name : instance name
    */
   function new(input string name = "");
      super.new(name);
   endfunction

   /* body() task implementation
    */
   virtual task body();
      repeat(m_nof_items) begin
         m_seq_item = endec_8b10b_ve_encoder_seq_item::type_id::create("m_seq_item",,get_full_name());
         start_item(m_seq_item);
         if (!m_seq_item.randomize()) begin
            `uvm_fatal(get_type_name(), "Randomization failed.")
         end
         finish_item(m_seq_item);
      end
   endtask
endclass


/* Sequence for control symbols only
 */
class endec_8b10b_ve_encoder_all_k_seq extends endec_8b10b_ve_encoder_seq;
   `uvm_object_utils(endec_8b10b_ve_encoder_all_k_seq)

   /* Default constructor
    * @param name : instance name
    */
   function new(input string name = "");
      super.new(name);
   endfunction

   /* body() task implementation
    */
   virtual task body();
      repeat(m_nof_items) begin
         m_seq_item = endec_8b10b_ve_encoder_seq_item::type_id::create("m_seq_item",,get_full_name());
         start_item(m_seq_item);
         if (!(m_seq_item.randomize() with {m_is_k_symbol == 1;})) begin
            `uvm_fatal(get_type_name(), "Randomization failed.")
         end
         finish_item(m_seq_item);
      end
   endtask
endclass

/* Sequence for data symbols only
 */
class endec_8b10b_ve_encoder_all_d_seq extends endec_8b10b_ve_encoder_seq;
   `uvm_object_utils(endec_8b10b_ve_encoder_all_d_seq)

   /* Default constructor
    * @param name : instance name
    */
   function new(input string name = "");
      super.new(name);
   endfunction

   /* body() task implementation
    */
   virtual task body();
      repeat(m_nof_items) begin
         m_seq_item = endec_8b10b_ve_encoder_seq_item::type_id::create("m_seq_item",,get_full_name());
         start_item(m_seq_item);
         if (!(m_seq_item.randomize() with {m_is_k_symbol == 0;})) begin
            `uvm_fatal(get_type_name(), "Randomization failed.")
         end
         finish_item(m_seq_item);
      end
   endtask
endclass

`endif//ENDEC_8b10b_VE_SEQ_LIB_SVH
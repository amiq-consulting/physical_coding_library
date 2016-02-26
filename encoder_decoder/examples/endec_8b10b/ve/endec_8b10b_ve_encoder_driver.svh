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
 * MODULE:      endec_8b10b_ve_encoder_driver.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the driver used for sending symbols
 *              to the encoder
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_ENCODER_DRIVER_SVH
`define ENDEC_8b10b_VE_ENCODER_DRIVER_SVH


/* Encoder driver
 */
class endec_8b10b_ve_encoder_driver extends uvm_driver#(endec_8b10b_ve_encoder_seq_item);
   `uvm_component_utils(endec_8b10b_ve_encoder_driver)


   // Encoder
   endec_8b10b_encoder m_encoder_h;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_ve_encoder_seq_item) m_symb_8b_analysis_port;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_ve_decoder_seq_item) m_symb_10b_analysis_port;

   // Put port to sent items to the decoder sequencer
   uvm_blocking_put_port#(endec_8b10b_ve_decoder_seq_item) m_dec_seqr_put_port;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(input string name, input uvm_component parent);
      super.new(name, parent);
      m_symb_8b_analysis_port = new("m_symb_8b_analysis_port", this);
      m_symb_10b_analysis_port = new("m_symb_10b_analysis_port", this);
   endfunction

   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      m_encoder_h = endec_8b10b_encoder::type_id::create("m_encoder_h", this);

      m_dec_seqr_put_port = new("m_dec_seqr_put_port", this);
   endfunction


   /* UVM run phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);

      endec_8b10b_ve_encoder_seq_item tx;
      // struct used as input for the encoder encode() function
      endec_8b10b_enc_in_dec_out_s encoder_in_s;
      

      forever begin

         endec_8b10b_ve_decoder_seq_item encoded_tx = endec_8b10b_ve_decoder_seq_item::type_id::create("encoded_tx_enc_drv");
         int current_disp = m_encoder_h.m_running_disp;

         seq_item_port.get_next_item(tx);
         m_symb_8b_analysis_port.write(tx);

         //populate encoder input struct
         encoder_in_s.enc_dec_8b_val = tx.m_data;
         encoder_in_s.is_k_symbol = tx.m_is_k_symbol;


         //populate the sequence item with the output struct contents
         encoded_tx.m_encoded_symbol = m_encoder_h.encode(encoder_in_s);

         m_symb_10b_analysis_port.write(encoded_tx);

         m_dec_seqr_put_port.put(encoded_tx);

         seq_item_port.item_done();
      end

   endtask

endclass

`endif//ENDEC_8b10b_VE_ENCODER_DRIVER_SVH
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
 * MODULE:      endec_8b10b_ve_decoder_driver.sv
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the driver used for sending symbols 
 * to the decoder
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_DECODER_DRIVER_SVH
`define ENDEC_8b10b_VE_DECODER_DRIVER_SVH

/* Decoder driver
 */
class endec_8b10b_ve_decoder_driver extends uvm_driver#(endec_8b10b_ve_decoder_seq_item);
   `uvm_component_utils(endec_8b10b_ve_decoder_driver)

   // Decoder
   endec_8b10b_decoder m_decoder_h;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_ve_encoder_seq_item) m_symb_8b_analysis_port;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_ve_decoder_seq_item) m_symb_10b_analysis_port;

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
      m_decoder_h = endec_8b10b_decoder::type_id::create("m_decoder_h", this);
   endfunction

   /* UVM run phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);
      //sequence item
      endec_8b10b_ve_decoder_seq_item tx;
      //struct holding the output from the decoder
      endec_8b10b_enc_in_dec_out_s decoder_out_s;
      
      forever begin
         endec_8b10b_ve_encoder_seq_item decoded_tx = endec_8b10b_ve_encoder_seq_item::type_id::create("decoded_tx_dec_drv");
         seq_item_port.get_next_item(tx);
         m_symb_10b_analysis_port.write(tx);

         decoder_out_s = m_decoder_h.decode(tx.m_encoded_symbol);
         //if errors signal error
         ENDEC_8b10b_DECODE_ERROR: assert (decoder_out_s.decode_err == 0) else
         `uvm_error("ENDEC_8b10b_DECODE_ERROR", "Item received from decoder contains errors.")
         
         decoded_tx.m_data = decoder_out_s.enc_dec_8b_val;
         decoded_tx.m_is_k_symbol = decoder_out_s.is_k_symbol;

         m_symb_8b_analysis_port.write(decoded_tx);
         seq_item_port.item_done();
      end
   endtask

endclass

`endif//ENDEC_8b10b_VE_DECODER_DRIVER_SVH
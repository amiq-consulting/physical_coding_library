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
 * MODULE:      endec_8b10b_ve_scb.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the scoreboard implementation
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_SCB_SVH
`define ENDEC_8b10b_VE_SCB_SVH

`uvm_analysis_imp_decl(_from_encoder_drv)
`uvm_analysis_imp_decl(_from_decoder_drv)

/* Scoreboard class
 */
class endec_8b10b_ve_scb extends uvm_scoreboard;

   // analysis ports that report items from encoder driver to the checked
   uvm_analysis_imp_from_encoder_drv#(endec_8b10b_ve_encoder_seq_item, endec_8b10b_ve_scb) m_encoder_drv_ap;

   // analysis ports that report items from decoder driver to the checked
   uvm_analysis_imp_from_decoder_drv#(endec_8b10b_ve_encoder_seq_item, endec_8b10b_ve_scb) m_decoder_drv_ap;

   // Provide implementations of virtual methods such as get_type_name and create
   `uvm_component_utils(endec_8b10b_ve_scb)


   // list of items received from encoder driver
   endec_8b10b_ve_encoder_seq_item m_items_enc_drv[$];

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new (input string name, input uvm_component parent);
      super.new(name, parent);

      m_encoder_drv_ap = new("m_encoder_drv_ap", this);
      m_decoder_drv_ap = new("m_decoder_drv_ap", this);
   endfunction : new

   /* Function that saves the item received from the encoder
    * @param a_enc_drv_item - item received from the encoder agent driver
    */
   virtual function void write_from_encoder_drv (endec_8b10b_ve_encoder_seq_item a_enc_drv_item);
      m_items_enc_drv.push_back(a_enc_drv_item);
      `uvm_info("SCB_8b10b", $sformatf("Received item from encoder with value = %x and is_k_symbol = %x",
            a_enc_drv_item.m_data, a_enc_drv_item.m_is_k_symbol), UVM_HIGH)
   endfunction

   /* Function performs scoreboarding each time it received a decoded item
    * @param a_dec_drv_item - item received from the decoder driver
    */
   virtual function void write_from_decoder_drv (endec_8b10b_ve_encoder_seq_item a_dec_drv_item);
      `uvm_info("SCB_8b10b", $sformatf("Received item from decoder with value = %x and is_k_symbol = %x",
            a_dec_drv_item.m_data, a_dec_drv_item.m_is_k_symbol), UVM_HIGH)
      if (m_items_enc_drv.size() == 0) begin
         `uvm_error("SCB_8b10b", $sformatf("Decoder reported an item while list of items from the driver is empty"))
      end

      begin
         endec_8b10b_ve_encoder_seq_item expected_item = m_items_enc_drv.pop_front();

         if (expected_item.m_data != a_dec_drv_item.m_data) begin
            `uvm_error("SCB_8b10b", $sformatf("Difference between decoded symbol value %x and encoded item %x",
                  a_dec_drv_item.m_data, expected_item.m_data))
         end
         else if (expected_item.m_is_k_symbol != a_dec_drv_item.m_is_k_symbol) begin
            `uvm_error("SCB_8b10b", $sformatf("Difference between decoded symbol type %x and encoded item type %x",
                  a_dec_drv_item.m_is_k_symbol, expected_item.m_is_k_symbol))
         end
         else `uvm_info("SCB_8b10b", $sformatf("Scoreboarding passed for decoded value = %x with is_k_symbol = %x",
                  a_dec_drv_item.m_data, a_dec_drv_item.m_is_k_symbol), UVM_HIGH)
      end
   endfunction

endclass

`endif//ENDEC_8b10b_VE_SCB_SVH

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
 * MODULE:      endec_64b66b_ve_scoreboard.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This file contains the scoreboard component
 *******************************************************************************/
`ifndef ENDEC_64b66b_VE_SCOREBOARD_SVH
`define ENDEC_64b66b_VE_SCOREBOARD_SVH
/* Scoreboard class
 *
 */
class endec_64b66b_ve_scoreboard extends uvm_component;
   `uvm_component_utils(endec_64b66b_ve_scoreboard)


   // analysis ports that report items from drivers to the checked
   // uvm_analysis_imp_before_encoder_drv#(endec_64b66b_seq_item, endec_64b66b_scoreboard) item_before_encoder_drv;
   uvm_analysis_imp #(endec_64b66b_ve_seq_item, endec_64b66b_ve_scoreboard)  m_decoded_item_ap;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // allocate the analysis port
      m_decoded_item_ap = new("m_decoded_item_ap", this);
   endfunction


   /* Analysis port write() implementation
    * @param a_decoded_item : input item from the driver received after decoding process
    */
   virtual function void write(endec_64b66b_ve_seq_item a_decoded_item);
      string error_msg;
      // handle to the decoder used to retrieve the decoding state
      endec_64b66b_decoder decoder_handle;
      // variable where state of decoder is updated
      endec_64b66b_receive_sm_states_e decoder_state;

      uvm_component parent = this.get_parent();

      // get handle to the decoder
      assert ($cast(decoder_handle, parent.lookup("m_agent_64b66b.m_driver_64b66b.m_decoder_64b66b"))) else
         `uvm_error("SB_64b66b", "Cast has failed.")
      decoder_state = decoder_handle.get_current_tx_state();

      if ((a_decoded_item.m_tx_block_type != E_BLOCK) & (decoder_state != RX_E)) begin

         if (a_decoded_item.m_control0 != a_decoded_item.m_decoded_xgmii_data[71:68]) begin
            error_msg = $sformatf("%s\nDifference between control0 input %x and decoded output %x",
               error_msg, a_decoded_item.m_control0, a_decoded_item.m_decoded_xgmii_data[71:68]);
         end
         if (a_decoded_item.m_data0 != a_decoded_item.m_decoded_xgmii_data[67:36]) begin
            error_msg = $sformatf("%s\nDifference between data0 input %x and decoded output %x",
               error_msg, a_decoded_item.m_data0, a_decoded_item.m_decoded_xgmii_data[67:36]);
         end
         if (a_decoded_item.m_control1 != a_decoded_item.m_decoded_xgmii_data[35:32]) begin
            error_msg = $sformatf("%s\nDifference between control1 input %x and decoded output %x",
               error_msg, a_decoded_item.m_control1, a_decoded_item.m_decoded_xgmii_data[35:32]);
         end
         if (a_decoded_item.m_data1 != a_decoded_item.m_decoded_xgmii_data[31:0]) begin
            error_msg = $sformatf("%s\nDifference between data1 input %x and decoded output %x",
               error_msg, a_decoded_item.m_data1, a_decoded_item.m_decoded_xgmii_data[31:0]);
         end
      end else begin
         if (a_decoded_item.m_decoded_xgmii_data[71:68] != 4'hf) begin
            error_msg =
            $sformatf("%s\nDifference between control0 expected value for error block %x and decoded output %x",
               error_msg, 4'hf, a_decoded_item.m_decoded_xgmii_data[71:68]);
         end
         if (a_decoded_item.m_decoded_xgmii_data[67:36] != {4{E_CONTROL}}) begin
            error_msg =
            $sformatf("%s\nDifference between data0 expected value for error block %x and decoded output %x",
               error_msg, {4{E_CONTROL}}, a_decoded_item.m_decoded_xgmii_data[67:36]);
         end
         if (a_decoded_item.m_decoded_xgmii_data[35:32] != 4'hf) begin
            error_msg =
            $sformatf("%s\nDifference between control1 expected value for error block %x and decoded output %x",
               error_msg, a_decoded_item.m_control1, a_decoded_item.m_decoded_xgmii_data[35:32]);
         end
         if (a_decoded_item.m_decoded_xgmii_data[31:0] != {4{E_CONTROL}}) begin
            error_msg =
            $sformatf("%s\nDifference between data1 expected value for error block %x and decoded output %x",
               error_msg, {4{E_CONTROL}}, a_decoded_item.m_decoded_xgmii_data[31:0]);
         end

      end

      // output error if error string is not empty
      if (error_msg != "") begin
         `uvm_error("SB_64b66b", error_msg)
      end else begin
         `uvm_info("SB_64b66b", "Scoreboarding passed", UVM_MEDIUM)
      end


   endfunction

endclass

`endif//ENDEC_64b66b_VE_SCOREBOARD_SVH
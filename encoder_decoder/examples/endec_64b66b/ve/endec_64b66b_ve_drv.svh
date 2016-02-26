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
 * MODULE:      endec_64b66b_ve_drv.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This file contains the driver used for sending symbols 
 *              to the encoder
 *******************************************************************************/

`ifndef ENDEC_64b66b_VE_DRV_SVH
`define ENDEC_64b66b_VE_DRV_SVH


/* Driver class
 *
 */
class endec_64b66b_ve_drv extends uvm_driver#(endec_64b66b_ve_seq_item);
   `uvm_component_utils(endec_64b66b_ve_drv)


   // analysis port that broadcasts all items outputted by the decoding function
   uvm_analysis_port#(endec_64b66b_ve_seq_item) m_post_decode_item_ap;


   // encoder handler
   endec_64b66b_encoder m_encoder_64b66b;
   // decoder handler
   endec_64b66b_decoder m_decoder_64b66b;


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
      //encoder instance
      m_encoder_64b66b = endec_64b66b_encoder::type_id::create("m_encoder_64b66b", this);
      //decoder instance
      m_decoder_64b66b = endec_64b66b_decoder::type_id::create("m_decoder_64b66b", this);

      // analysis port
      m_post_decode_item_ap = new("m_post_decode_item_ap", this);
   endfunction


   /* UVM connect_phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction


   /* UVM run_phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);
      endec_64b66b_ve_seq_item encoder_item;


      forever begin
         // get item from the sequencer
         seq_item_port.get_next_item(encoder_item);

         // print item
         `uvm_info("DRIVER_64b66b", encoder_item.convert2string(), UVM_HIGH)

         // encode
         encoder_item.m_code_block_66b = m_encoder_64b66b.encode({encoder_item.m_control1,encoder_item.m_data1,
            encoder_item.m_control0, encoder_item.m_data0});
         // update block type of the packet after encoding process has been performed
         encoder_item.m_tx_block_type = m_encoder_64b66b.get_tx_block_format();
         `uvm_info("DRIVER_64b66b", $sformatf("\nEncoder output = %x " , encoder_item.m_code_block_66b), UVM_MEDIUM)

         // decode         
         encoder_item.m_decoded_xgmii_data = m_decoder_64b66b.decode(encoder_item.m_code_block_66b);
         `uvm_info("DECODER_64b66b", 
            $sformatf("\Decoder output \ncontrol0 = %x \ndata0    = %x \ncontrol1 = %x \ndata1    = %x \n", 
               encoder_item.m_decoded_xgmii_data[71:68], encoder_item.m_decoded_xgmii_data[67:36], 
               encoder_item.m_decoded_xgmii_data[35:32], encoder_item.m_decoded_xgmii_data[31:0]), UVM_HIGH)


         // send item to scoreboard
         m_post_decode_item_ap.write(encoder_item);

         seq_item_port.item_done();
      end
   endtask

endclass

`endif//ENDEC_64b66b_VE_DRV_SVH

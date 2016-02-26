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
 * MODULE:      endec_8b10b_ve_encoder_seq_item.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the item that will be encoded
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_ENCODER_SEQ_ITEM_SVH
`define ENDEC_8b10b_VE_ENCODER_SEQ_ITEM_SVH

/* Decoder sequence item
 */
class endec_8b10b_ve_encoder_seq_item extends uvm_sequence_item;
   `uvm_object_utils(endec_8b10b_ve_encoder_seq_item)

   //if set means the byte to be encoded is
   //a control symbol
   rand bit m_is_k_symbol;
   //un-encoded/decoded data byte
   rand bit[7:0] m_data;

   //constrain to generate valid control symbols when flag is set
   constraint k_symb {
      if (m_is_k_symbol == 1) {
         m_data inside {K_28_0_8B, K_28_1_8B, K_28_2_8B, K_28_3_8B, K_28_4_8B,
            K_28_5_8B, K_28_6_8B, K_28_7_8B, K_23_7_8B, K_27_7_8B, K_29_7_8B, K_30_7_8B};
      }
   }

   /* Default constructor
    * @param name : instance name
    */
   function new (input string name="8b10b_data_to_encode_trans");
      super.new(name);
   endfunction

endclass

`endif//ENDEC_8b10b_VE_ENCODER_SEQ_ITEM_SVH

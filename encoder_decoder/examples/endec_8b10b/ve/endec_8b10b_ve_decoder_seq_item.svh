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
 * MODULE:      endec_8b10b_ve_decoder_seq_item.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the item that will be decoded
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_DECODER_SEQ_ITEM_SVH
`define ENDEC_8b10b_VE_DECODER_SEQ_ITEM_SVH

/* Decoder sequence item
 */
class endec_8b10b_ve_decoder_seq_item extends uvm_sequence_item;

   `uvm_object_utils(endec_8b10b_ve_decoder_seq_item)
   // 8b10b encoded symbol
   rand bit [9:0] m_encoded_symbol;  

   /* Default constructor
    * @param name : instance name
    */
   function new (input string name="8b10b_encoded_data_trans");
      super.new(name);
   endfunction

endclass

`endif//ENDEC_8b10b_VE_DECODER_SEQ_ITEM_SVH

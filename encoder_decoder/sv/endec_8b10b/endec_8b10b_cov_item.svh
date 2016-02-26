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
 * MODULE:      endec_8b10b_cov_item.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains classes holding the coverage information
 *****************************************************************************/

`ifndef ENDEC_8b10b_COV_ITEM_SVH
`define ENDEC_8b10b_COV_ITEM_SVH


/* Class holding coverage information related to the
 * uncoded data
 */
class endec_8b10b_cov_data extends uvm_object;
   `uvm_object_utils(endec_8b10b_cov_data)

   //if set means the byte to be encoded 
   //or the one that's been decoded is
   //a control symbol
   bit m_is_k_symbol;
      
   //un-encoded/decoded data byte
   bit[7:0] m_data;
   
   //encoded symbol, output of the encoder
   //or input of the decoder
   bit[9:0] m_encoded_symb;
   
   //field holding disparity before
   //processing (for encoding and decoding)
   int m_pre_disp;
   //field holding disparity after
   //processing (for encoding and decoding)
   int m_post_disp;

   /* Constructor
    * @param name : name for this instance
    */
   function new(input string name="endec_8b10b_cov_data");
      //class constructor
      super.new(name);
   endfunction
endclass

`endif//ENDEC_8b10b_COV_ITEM_SVH

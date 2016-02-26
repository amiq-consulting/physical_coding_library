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
 * MODULE:      endec_64b66b_cov_items.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: Classes holding the coverage information
 *******************************************************************************/

`ifndef ENDEC_64b66b_COV_ITEMS_SVH
`define ENDEC_64b66b_COV_ITEMS_SVH

 /* Class holding the coverage points to be send
 * to the decoder coverage class
 */
class endec_64b66b_encoder_cov_c extends uvm_object;
   `uvm_object_utils(endec_64b66b_encoder_cov_c)

   // holds state of the transmit state machine
   endec_64b66b_transmit_sm_states_e m_transmit_state;

   // this bit will tell if the block formats should
   // be used for coverage for a struct instance
   bit m_tx_blk_formats_sampled;
   // this bit is used for the cross coverage to avoid
   // cross coverage on input when the previous input does not exist
   bit m_first_sample_done;
   // holds current format
   endec_64b66b_block_formats_e m_tx_blk_format;
   // holds previous format
   endec_64b66b_block_formats_e m_prev_tx_blk_format;

   /* Constructor
    * @param name : name for this instance
    */
   function  new(input string name= "endec_64b66b_encoder_cov_c");
      super.new(name);
   endfunction

endclass
 

/* Class holding the coverage points to be send
 * to the decoder coverage class
 */
class endec_64b66b_decoder_cov_c extends uvm_object;
   `uvm_object_utils(endec_64b66b_decoder_cov_c)

   // holds current state of the state machine
   endec_64b66b_receive_sm_states_e m_receive_state;

   // this bit will tell if the block formats should
   // be used for coverage for a class instance
   bit m_rx_blk_formats_sampled;
   // this bit is used for the cross coverage to avoid
   // cross coverage on input when the previous input does not exist
   bit m_first_sample_done;
   // holds current format
   endec_64b66b_block_formats_e m_rx_blk_format;
   // holds previous format
   endec_64b66b_block_formats_e m_prev_rx_blk_format;

   /* Constructor
    * @param name : name for this instance
    */
   function  new(input string name= "endec_64b66b_decoder_cov_c");
      super.new(name);
   endfunction

endclass

`endif //ENDEC_64b66b_COV_ITEMS_SVH
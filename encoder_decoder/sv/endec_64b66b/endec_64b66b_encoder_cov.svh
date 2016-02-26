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
 * MODULE:      endec_64b66b_encoder_cov.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the implementation file of the 64b/66b encoder coverage
 *              class that's part of endec_64b66b package
 *******************************************************************************/

`ifndef ENDEC_64b66b_ENCODER_COV_SVH
`define ENDEC_64b66b_ENCODER_COV_SVH


/* Encoder coverage class
 * Receives the coverage data from the encoder component
 */
class endec_64b66b_encoder_cov extends uvm_component;
   `uvm_component_utils(endec_64b66b_encoder_cov)


   // receives the structure containing data from the encoder to be covered
   uvm_analysis_imp #(endec_64b66b_encoder_cov_c, endec_64b66b_encoder_cov)  m_get_data_to_cov_ai;


   // cover the evolution of the transmit state machine
   covergroup cg_transmit_state with function sample(endec_64b66b_transmit_sm_states_e transmit_state);
      STATE: coverpoint transmit_state
      {
         bins transmit_state [] = (TX_C, TX_D, TX_T, TX_E => TX_C, TX_D, TX_T, TX_E);
         illegal_bins illegal = (TX_C => TX_T), (TX_D => TX_C), (TX_T => TX_T);
         type_option.comment = "Transition of state machine states.";
      }
   endgroup

   // cover the format of the blocks
   covergroup cg_transmit_blk_format with function sample(endec_64b66b_block_formats_e tx_block_format);
      BLK_FORMAT: coverpoint tx_block_format
      {
         type_option.comment = "Coverage of the type of the transmitted block formats.";
      }
   endgroup

   // cross between two consecutive block formats
   covergroup cg_transmit_blk_format_cross with function sample(
         endec_64b66b_block_formats_e m_prev_tx_blk_format, endec_64b66b_block_formats_e m_tx_blk_format
      );
      BLK_FORMAT_TRANS: cross m_prev_tx_blk_format, m_tx_blk_format
      {
         ignore_bins ignore =
         // illegal case if we go from C_block to D_block or T_block
         (
            binsof (m_prev_tx_blk_format) intersect  {
               ALL_CONTROL_FORMAT, CONTROL_ORDSET_FORMAT, ORDSET_ORDSET_FORMAT, ORDSET_CONTROL_FORMAT
            }
            &&
            binsof (m_tx_blk_format) intersect {
               ALL_DATA_FORMAT, TERMINATE7_FORMAT, TERMINATE6_FORMAT, TERMINATE5_FORMAT, TERMINATE4_FORMAT,
               TERMINATE3_FORMAT, TERMINATE2_FORMAT, TERMINATE1_FORMAT, TERMINATE0_FORMAT
            }
         )
         ||
         // illegal case if we go from S_block to C_block or S_block
         (
            binsof (m_prev_tx_blk_format) intersect  {
               CONTROL_START_FORMAT, ORDSET_START_FORMAT, START_DATA_FORMAT
            }
            &&
            binsof (m_tx_blk_format) intersect {
               ALL_CONTROL_FORMAT, CONTROL_ORDSET_FORMAT, ORDSET_ORDSET_FORMAT, ORDSET_CONTROL_FORMAT,
               CONTROL_START_FORMAT, ORDSET_START_FORMAT, START_DATA_FORMAT
            }
         )
         ||
         // illegal case if we go from D_block to  C_block or S_block
         (
            binsof (m_prev_tx_blk_format) intersect  {ALL_DATA_FORMAT}
            &&
            binsof (m_tx_blk_format) intersect {
               ALL_CONTROL_FORMAT, CONTROL_ORDSET_FORMAT, ORDSET_ORDSET_FORMAT, ORDSET_CONTROL_FORMAT,
               CONTROL_START_FORMAT, ORDSET_START_FORMAT, START_DATA_FORMAT
            }
         )
         ||
         // illegal case if we go from T_block to D_block or T_block
         (
            binsof (m_prev_tx_blk_format) intersect  {
               TERMINATE7_FORMAT, TERMINATE6_FORMAT, TERMINATE5_FORMAT, TERMINATE4_FORMAT, TERMINATE3_FORMAT,
               TERMINATE2_FORMAT, TERMINATE1_FORMAT, TERMINATE0_FORMAT
            }
            &&
            binsof (m_tx_blk_format) intersect {
               ALL_DATA_FORMAT, TERMINATE7_FORMAT, TERMINATE6_FORMAT, TERMINATE5_FORMAT, TERMINATE4_FORMAT,
               TERMINATE3_FORMAT, TERMINATE2_FORMAT, TERMINATE1_FORMAT, TERMINATE0_FORMAT
            }
         );
         type_option.comment = "Cross between previously and currently transmitted block formats.";
      }
   endgroup


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(string name, uvm_component parent);
      super.new(name, parent);

      cg_transmit_state = new();
      cg_transmit_blk_format = new();
      cg_transmit_blk_format_cross = new();
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      // allocate the analysis implementation
      m_get_data_to_cov_ai = new("m_get_data_to_cov_ai", this);
   endfunction


   /*  write() function implementation
    * @param a_cov_data : input item from the driver received after decoding process
    */
   virtual function void write(endec_64b66b_encoder_cov_c a_cov_data);
      `uvm_info("ENCODER_64b66b_COVERAGE", $sformatf("%b", a_cov_data.m_first_sample_done), UVM_MEDIUM)
      `uvm_info("ENCODER_64b66b_COVERAGE", $sformatf("%s", a_cov_data.m_transmit_state), UVM_MEDIUM)


      cg_transmit_state.sample(a_cov_data.m_transmit_state);
      if (a_cov_data.m_tx_blk_formats_sampled == 1) begin
         cg_transmit_blk_format.sample(a_cov_data.m_tx_blk_format);
         if (a_cov_data.m_first_sample_done == 1) begin
            cg_transmit_blk_format_cross.sample(a_cov_data.m_prev_tx_blk_format ,a_cov_data.m_tx_blk_format);
         end
      end
   endfunction

endclass

`endif//ENDEC_64b66b_ENCODER_COV_SVH
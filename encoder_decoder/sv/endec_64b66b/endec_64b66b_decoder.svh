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
 * MODULE:      endec_64b66b_decoder.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the implementation file of the 64b/66b decoder that's part
 *              of endec_64b66b package
 *******************************************************************************/
`ifndef ENDEC_64b66b_DECODER_SVH
`define ENDEC_64b66b_DECODER_SVH


/* Decoder class
 * Receives the 64bits data input and outputs the corresponding 66bits encoded symbol
 */
class endec_64b66b_decoder extends uvm_component;
   `uvm_component_utils(endec_64b66b_decoder)


   // analysis port that broadcasts the coverage data to be covered
   uvm_analysis_port#(endec_64b66b_decoder_cov_c) m_data_to_cov_ap;

   // coverage class
   endec_64b66b_decoder_cov m_decoder_cov;
   // struct used to send the coverage data
   endec_64b66b_decoder_cov_c m_dec_cov_data;


   // variables that hold the evolution of the state machine
   // current received state
   local endec_64b66b_receive_sm_states_e m_receive_state;
   // previous received state
   local endec_64b66b_receive_sm_states_e m_prev_receive_state;


   // variable holding the format of the transmitted blocks
   // current rx block format
   local endec_64b66b_block_formats_e m_rx_blk_format;
   // previous rx block format
   local endec_64b66b_block_formats_e m_prev_rx_blk_format;
   // variable set after the first sample of rx_block_format variable
   bit m_first_sample_done;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new (string name , uvm_component parent);
      super.new(name, parent);

      m_data_to_cov_ap = new("m_data_to_cov_ap", this);
   endfunction


   /* Function returning the current state of decoder
    *  @return value of field holding the current state
    */
   virtual function endec_64b66b_receive_sm_states_e get_current_tx_state();
      return m_receive_state;
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // create the coverage class
      m_decoder_cov = endec_64b66b_decoder_cov::type_id::create("m_decoder_cov", this);
   endfunction


   /* R_BLOCK_TYPE standard function implementation
    * @param a_coded_block_in : 66bits coded block
    * @return input data block type
    */
   local function endec_64b66b_rx_tx_block_type_e pma_bytes_to_r_block_type (bit[65:0] a_coded_block_in);
      // holds the candidate output with the final result is being computed
      endec_64b66b_rx_tx_block_type_e candidate_r_blk_type;

      if (a_coded_block_in[65:64] == 2'b01) begin
         candidate_r_blk_type = D_BLOCK;
      end
      else if (a_coded_block_in[65:64] == 2'b10) begin
         case (a_coded_block_in[63:56])
            8'h1e: candidate_r_blk_type = (a_coded_block_in[55:0]  == {8{7'b0}})        ? C_BLOCK : E_BLOCK;//only IDLEs are allowed here
            8'h2d: candidate_r_blk_type = ((a_coded_block_in[27:24] == 4'b0) &&
                  (check_valid_codes(a_coded_block_in[55:28],4) == 1))   ? C_BLOCK : E_BLOCK;//can be idle or error
            8'h33: candidate_r_blk_type = ((a_coded_block_in[27:24] == 4'b0) &&
                  (check_valid_codes(a_coded_block_in[55:28],4) == 1))   ? S_BLOCK : E_BLOCK;//can be idle or error
            8'h66: candidate_r_blk_type = (a_coded_block_in[31:24] == {4'b0,4'b0})      ? S_BLOCK : E_BLOCK;
            8'h55: candidate_r_blk_type = (a_coded_block_in[31:24] == {4'b0,4'b0})      ? C_BLOCK : E_BLOCK;
            8'h78: candidate_r_blk_type = S_BLOCK;
            8'h4b: candidate_r_blk_type = ((a_coded_block_in[31:28] == 4'b0) &&
                  (check_valid_codes(a_coded_block_in[27:0],4) == 1))      ? C_BLOCK : E_BLOCK;//can be idle or error
            8'h87: candidate_r_blk_type = ((a_coded_block_in[55:49] == 7'b0) &&
                  (check_valid_codes(a_coded_block_in[48:0],7) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'h99: candidate_r_blk_type = ((a_coded_block_in[47:42] == 6'b0) &&
                  (check_valid_codes(a_coded_block_in[41:0],6) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'haa: candidate_r_blk_type = ((a_coded_block_in[39:35] == 5'b0) &&
                  (check_valid_codes(a_coded_block_in[34:0],5) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'hb4: candidate_r_blk_type = ((a_coded_block_in[31:28] == 4'b0) &&
                  (check_valid_codes(a_coded_block_in[27:0],4) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'hcc: candidate_r_blk_type = ((a_coded_block_in[23:21] == 3'b0) &&
                  (check_valid_codes(a_coded_block_in[20:0],3) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'hd2: candidate_r_blk_type = ((a_coded_block_in[15:14] == 2'b0) &&
                  (check_valid_codes(a_coded_block_in[13:0],2) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'he1: candidate_r_blk_type = ((a_coded_block_in[7:7]   == 1'b0) &&
                  (check_valid_codes(a_coded_block_in[6:0] ,1) == 1))      ? T_BLOCK : E_BLOCK;//can be idle or error
            8'hff: candidate_r_blk_type = T_BLOCK;
            default: candidate_r_blk_type = E_BLOCK; // no defined block so error
         endcase
      end
      else begin
         candidate_r_blk_type = E_BLOCK;
      end

      return candidate_r_blk_type;
   endfunction


   /* Function that checks if selected part of the received data has only IDLE and/or ERROR 10GBASE-R codes
    * @param a_coded_blk_to_check : a multiple of 7bit that is a continuous part of the coded payload
    * @param a_num_7bit_slices_to_check : the number of 7bit groups from the coded payload to be checked
    */
   local function bit check_valid_codes (bit[63:0] a_coded_blk_to_check, bit[2:0] a_num_7bit_slices_to_check);
      bit check_res = 1;
      for (int iter = 0; iter < a_num_7bit_slices_to_check; iter++) begin
         // check for IDLE and ERROR code values
         if (!(a_coded_blk_to_check[(7*(1+iter))-1 -: 7] inside {7'b0, 7'b0011110})) begin
            check_res = 0;
            break;
         end
      end
      return check_res;
   endfunction


   /* Function to return xgmii code characters from the 10gbase-r control codes
    * applies to IDLE and ERROR codes only
    * @param a_coded_blk_slice_to_convert : a 7bit multiple slice from the coded payload to be converted to
    *                                     same number of 8bit xgmii cotrol codes
    * @param a_num_7bit_slice_to_convert : number of 7bit slices to convert
    */
   local function bit[63:0] convert_to_xgmii_control_char (bit[63:0] a_coded_blk_slice_to_convert,
         bit[2:0] a_num_7bit_slice_to_convert);

      bit[63:0] converted_bits;
      for (int iter = 0; iter < a_num_7bit_slice_to_convert; iter++) begin
         // check for IDLE and ERROR code values
         if ((a_coded_blk_slice_to_convert[(7*(1+iter))-1 -: 7] inside {7'b0, 7'b0011110})) begin
            converted_bits[(8*(1+iter))-1 -: 8] = (a_coded_blk_slice_to_convert[(7*(1+iter))-1 -: 7] == 7'b0) ?
            8'b00000111 : 8'b11111110;
         end
      end

      return converted_bits;
   endfunction


   /* Receive state machine
    * states : RX_INIT, RX_C, RX_D, RX_T, RX_E
    * NOTE: this implements the receive state machine from the standard
    * but does not use R_TYPE_NEXT function that predicts based on the
    * packet following the currently processed one the correct transition
    * @param a_coded_block_in : the 66bit coded payload
    * @return 72bits representing the coded payload converted to the corresponding xgmii format
    *
    */
   virtual function bit [71:0] decode (bit[65:0] a_coded_block_in);
      bit[63:0] xgmii_data_temp;
      bit[7:0]  xgmii_ctrl_indication_temp;

      endec_64b66b_rx_tx_block_type_e current_r_blk_type;
      current_r_blk_type = pma_bytes_to_r_block_type (a_coded_block_in);

      m_prev_receive_state = m_receive_state;

      case (m_receive_state)
         RX_INIT: m_receive_state = (current_r_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            RX_E : ((current_r_blk_type == S_BLOCK) ? RX_D : RX_C);
         RX_C   : m_receive_state = (current_r_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            RX_E : ((current_r_blk_type == S_BLOCK) ? RX_D : RX_C);
         RX_D   : m_receive_state = (current_r_blk_type inside {E_BLOCK, C_BLOCK, S_BLOCK}) ?
            RX_E : ((current_r_blk_type == T_BLOCK) ? RX_T : RX_D);
         RX_T   : m_receive_state = (current_r_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            RX_E : ((current_r_blk_type == S_BLOCK) ? RX_D : RX_C);
         RX_E   : m_receive_state = (current_r_blk_type inside {E_BLOCK, S_BLOCK})          ?
            RX_E : ((current_r_blk_type == T_BLOCK) ? RX_T : ((current_r_blk_type == C_BLOCK) ? RX_C : RX_D));
      endcase


      // print current transmit state
      `uvm_info("DECODER_64b66b", $sformatf("Current state of the receive state machine is  %s", m_receive_state),
         UVM_MEDIUM)

      //decoder_cov_data = new();
      m_dec_cov_data = endec_64b66b_decoder_cov_c::type_id::create("m_dec_cov_data");

      if (m_receive_state inside {RX_C, RX_D, RX_T}) begin
         // update previous block format field if this is not the first time
         // we enter here
         if (m_first_sample_done) begin
            m_prev_rx_blk_format = m_rx_blk_format;
         end

         xgmii_data_temp = convert_to_xgmii_data (a_coded_block_in);
         xgmii_ctrl_indication_temp = convert_to_xgmii_control_indication (a_coded_block_in);

         m_first_sample_done = 1;

         m_dec_cov_data.m_rx_blk_format = m_rx_blk_format;
         m_dec_cov_data.m_prev_rx_blk_format = m_prev_rx_blk_format;
         m_dec_cov_data.m_first_sample_done = m_first_sample_done;
         m_dec_cov_data.m_rx_blk_formats_sampled = 1;

      end

      m_dec_cov_data.m_receive_state = m_receive_state;

      m_data_to_cov_ap.write(m_dec_cov_data);

      if (m_receive_state inside {RX_C, RX_D, RX_T}) begin
         return  {
            xgmii_ctrl_indication_temp[7:4], xgmii_data_temp[63:32],
            xgmii_ctrl_indication_temp[3:0], xgmii_data_temp[31:0]
         };
      end else begin
         return `R_EBLOCK_T;
      end

   endfunction


   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      m_data_to_cov_ap.connect(m_decoder_cov.m_get_data_to_cov_ai);
   endfunction


   /* Function returning the xgmii interface 64bits data block
    * this function is not entered if the format of the block is not recognized
    * @param a_coded_block_in : 66bit coded block
    * @return the decoded 64 bits of data
    */
   local function bit [63:0] convert_to_xgmii_data (bit[65:0] a_coded_block_in);  // this is actually the decode function
      bit[63:0] decoded_64bits;

      if (a_coded_block_in[65:64] == 2'b01) begin
         decoded_64bits = a_coded_block_in[63:0];
         m_rx_blk_format = ALL_DATA_FORMAT;
      end
      else if (a_coded_block_in[65:64] == 2'b10) begin

         // first transform the 10gbase-r control codes to xgmii control characters
         bit [63:0] converted_xgmii_ctrl_chars;


         case (endec_64b66b_block_type_field_e'(a_coded_block_in[63:56]))
            BLK_TYPE_0: begin
               decoded_64bits = {8{I_CONTROL}};
               m_rx_blk_format = ALL_CONTROL_FORMAT;
            end
            BLK_TYPE_1: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[55:28],4);//can be idle or error
               decoded_64bits = {converted_xgmii_ctrl_chars[31:0], Q_CONTROL, a_coded_block_in[23:0]};//can be idle or error
               m_rx_blk_format = CONTROL_ORDSET_FORMAT;
            end
            BLK_TYPE_2: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[55:28],4);
               decoded_64bits = {converted_xgmii_ctrl_chars[31:0], S_CONTROL, a_coded_block_in[23:0]};//can be idle or error
               m_rx_blk_format = CONTROL_START_FORMAT;
            end
            BLK_TYPE_3: begin
               decoded_64bits = {Q_CONTROL, a_coded_block_in[55:32], S_CONTROL, a_coded_block_in[23:0]};
               m_rx_blk_format = ORDSET_START_FORMAT;
            end
            BLK_TYPE_4: begin
               decoded_64bits = {Q_CONTROL, a_coded_block_in[55:32], Q_CONTROL, a_coded_block_in[23:0]};
               m_rx_blk_format = ORDSET_ORDSET_FORMAT;
            end
            BLK_TYPE_5: begin
               decoded_64bits = {S_CONTROL, a_coded_block_in[55:0]};
               m_rx_blk_format = START_DATA_FORMAT;
            end
            BLK_TYPE_6: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[27:0],4);
               decoded_64bits = {Q_CONTROL, a_coded_block_in[55:32], converted_xgmii_ctrl_chars[31:0]};//can be idle or error
               m_rx_blk_format = ORDSET_CONTROL_FORMAT;
            end
            BLK_TYPE_7: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[48:0],7);
               decoded_64bits = {T_CONTROL, converted_xgmii_ctrl_chars[55:0]};//can be idle or error
               m_rx_blk_format = TERMINATE7_FORMAT;
            end
            BLK_TYPE_8: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[41:0],6);
               decoded_64bits = {a_coded_block_in[55:48], T_CONTROL, converted_xgmii_ctrl_chars[47:0]};//can be idle or error
               m_rx_blk_format = TERMINATE6_FORMAT;
            end
            BLK_TYPE_9: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[34:0],5);
               decoded_64bits = {a_coded_block_in[55:40], T_CONTROL, converted_xgmii_ctrl_chars[39:0]};//can be idle or error
               m_rx_blk_format = TERMINATE5_FORMAT;
            end
            BLK_TYPE_10: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[27:0],4);
               decoded_64bits = {a_coded_block_in[55:32], T_CONTROL, converted_xgmii_ctrl_chars[31:0]};//can be idle or error
               m_rx_blk_format = TERMINATE4_FORMAT;
            end
            BLK_TYPE_11: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[20:0],3);
               decoded_64bits = {a_coded_block_in[55:24], T_CONTROL, converted_xgmii_ctrl_chars[23:0]};//can be idle or error
               m_rx_blk_format = TERMINATE3_FORMAT;
            end
            BLK_TYPE_12: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[13:0],2);
               decoded_64bits = {a_coded_block_in[55:16], T_CONTROL, converted_xgmii_ctrl_chars[15:0]};//can be idle or error
               m_rx_blk_format = TERMINATE2_FORMAT;
            end
            BLK_TYPE_13: begin
               converted_xgmii_ctrl_chars = convert_to_xgmii_control_char(a_coded_block_in[6:0] ,1);
               decoded_64bits = {a_coded_block_in[55:8] , T_CONTROL, converted_xgmii_ctrl_chars[7:0]};//can be idle or error
               m_rx_blk_format = TERMINATE1_FORMAT;
            end
            BLK_TYPE_14: begin
               decoded_64bits = {a_coded_block_in[55:0] , T_CONTROL};
               m_rx_blk_format = TERMINATE0_FORMAT;
            end
            default: decoded_64bits = {8{E_CONTROL}};
         endcase

      end
      else begin
         decoded_64bits = {8{E_CONTROL}};
      end

      return decoded_64bits;
   endfunction


   /* Function returning the xgmii interface byte type indication
    * @param a_coded_block_in : the 66bit coded block
    * @return the 8 bits holding the two 4bit xgmii interface signals that indicate
    *         the type of each of the 8 bytes contained in the decoded 64bits
    */
   local function bit [7:0] convert_to_xgmii_control_indication (bit[65:0] a_coded_block_in);  // this is actually the decode function for control indicators
      // will hold both control indication fields specific for the xgmii interface
      byte xgmii_tx_c_both;

      if (a_coded_block_in[65:64] == 2'b01) begin
         xgmii_tx_c_both = 0;
      end
      else if (a_coded_block_in[65:64] == 2'b10) begin
         case (a_coded_block_in[63:56])
            8'h1e: xgmii_tx_c_both = 8'hff;//{8{I_control}};
            8'h2d: xgmii_tx_c_both = 8'hf8;//{{4{I_control}}, Q_control, coded_block_in[23:0]};
            8'h33: xgmii_tx_c_both = 8'hf8;//{{4{I_control}}, S_control, coded_block_in[23:0]};
            8'h66: xgmii_tx_c_both = 8'h88;//{Q_control, coded_block_in[55:32], S_control, coded_block_in[23:0]};
            8'h55: xgmii_tx_c_both = 8'h88;//{Q_control, coded_block_in[55:32], Q_control, coded_block_in[23:0]};
            8'h78: xgmii_tx_c_both = 8'h80;//{S_control, coded_block_in[55:0]};
            8'h4b: xgmii_tx_c_both = 8'h8f;//{Q_control, coded_block_in[55:32], {4{I_control}}};
            8'h87: xgmii_tx_c_both = 8'hff;//{T_control, {7{I_control}}};
            8'h99: xgmii_tx_c_both = 8'h7f;//{coded_block_in[55:48], T_control, {6{I_control}}};
            8'haa: xgmii_tx_c_both = 8'h3f;//{coded_block_in[55:40], T_control, {5{I_control}}};
            8'hb4: xgmii_tx_c_both = 8'h1f;//{coded_block_in[55:32], T_control, {4{I_control}}};
            8'hcc: xgmii_tx_c_both = 8'h0f;//{coded_block_in[55:24], T_control, {3{I_control}}};
            8'hd2: xgmii_tx_c_both = 8'h07;//{coded_block_in[55:16], T_control, {2{I_control}}};
            8'he1: xgmii_tx_c_both = 8'h03;//{coded_block_in[55:8] , T_control, I_control};
            8'hff: xgmii_tx_c_both = 8'h01;//{coded_block_in[55:0] , T_control};
            default: xgmii_tx_c_both = 8'hff;//means we send error code on all bytes
         endcase
      end
      else begin
         xgmii_tx_c_both = 8'hff;//  {8{E_control}};
      end

      return xgmii_tx_c_both;
   endfunction

endclass

`endif
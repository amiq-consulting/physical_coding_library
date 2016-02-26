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
 * MODULE:      endec_64b66b_encoder.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the implementation file of the 64b/66b encoder that's part
 *              of endec_64b66b package
 *******************************************************************************/

`ifndef ENDEC_64b66b_ENCODER_SVH
`define ENDEC_64b66b_ENCODER_SVH


/* Encoder class
 * Receives the 64bits data input and outputs the corresponding 66bits encoded symbol
 */
class endec_64b66b_encoder extends uvm_component;
   `uvm_component_utils(endec_64b66b_encoder)


   // analysis port that broadcasts the coverage data to be covered
   uvm_analysis_port#(endec_64b66b_encoder_cov_c) m_data_to_cov_ap;


   // coverage class
   endec_64b66b_encoder_cov m_encoder_cov;
   // struct used to send the coverage data
   endec_64b66b_encoder_cov_c m_enc_cov_data;


   // variables that hold the evolution of the state machine
   // current transmit state
   local endec_64b66b_transmit_sm_states_e m_transmit_state;
   // previous transmit state
   local endec_64b66b_transmit_sm_states_e m_prev_transmit_state;


   // variable holding the format of the transmitted blocks
   endec_64b66b_block_formats_e m_tx_blk_format;
   // previous tx block format
   endec_64b66b_block_formats_e m_prev_tx_blk_format;
   // variable set after the first sample of tx_block_format variable
   bit m_first_sample_done;

   // variable holding the input block format
   local endec_64b66b_rx_tx_block_type_e m_current_t_blk_type;


   // holds the data/control block formats
   // this field is updated by function below
   // value of field corresponds to one of the formats in
   // figure 49-7-64B/66B block formats in up-down order
   local bit [3:0] m_current_blk_format;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new (string name , uvm_component parent);
      super.new(name, parent);

      m_data_to_cov_ap = new("m_data_to_cov_ap", this);
   endfunction


   /* Function returning the current state of encoder
    *  @return value of field holding the current state
    */
   virtual function endec_64b66b_transmit_sm_states_e get_current_rx_state();
      return m_transmit_state;
   endfunction


   /* Function returning the current block format
    *  @return current transmit block type value
    */
   virtual function endec_64b66b_rx_tx_block_type_e get_tx_block_format();
      return m_current_t_blk_type;
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      // create the coverage class
      m_encoder_cov = endec_64b66b_encoder_cov::type_id::create("m_encoder_cov", this);
   endfunction


   /* T_BLOCK_TYPE standard function implementation
    * @param a_blk_format_data_in : xgmii interface data input
    * @param a_tx_c0 : indicator of data/control input bytes of the xgmii interface
    * @param a_tx_c1 : indicator of data/control input bytes of the xgmii interface
    * @return input data block type
    */
   local function endec_64b66b_rx_tx_block_type_e xgmii_bytes_to_block_t_block_type (
         bit[63:0] a_blk_format_data_in,
         bit[3:0] a_tx_c0,
         bit[3:0] a_tx_c1
      );
      // array holds bytes converted in the xgmii notation
      endec_64b66b_xgmii_control_code_e bytes_to_xgmii_ctrl [8];
      byte tx_c_both = {a_tx_c0,a_tx_c1};
      // holds the candidate output with the final result is being computed
      endec_64b66b_rx_tx_block_type_e candidate_t_blk_type;

      // build array with xgmii control codes notation
      for (int iter=0; iter<8; iter++) begin
         bytes_to_xgmii_ctrl[7-iter] =control_byte_to_control_type(
            a_blk_format_data_in[(8*(8-iter))-1 -:8],tx_c_both[7:7]
         );
         tx_c_both <<= 1;
      end

      if ({a_tx_c0,a_tx_c1} == 8'h00) begin
         // case : DDDD/DDDD
         // update the block format
         m_current_blk_format = 0;
         candidate_t_blk_type = D_BLOCK;
      end else if ({a_tx_c0,a_tx_c1} == 8'hFF) begin
         // check cases : CCCC/CCCC - only idle's allowed
         //             : TCCC/CCCC - both idle and error allowed
         candidate_t_blk_type = (bytes_to_xgmii_ctrl[7] == T_CONTROL) ?
         T_BLOCK : ((bytes_to_xgmii_ctrl[7] == I_CONTROL) ? C_BLOCK : E_BLOCK);
         if (candidate_t_blk_type != E_BLOCK) begin
            if (candidate_t_blk_type == C_BLOCK) begin
               for (int iter=0; iter<7; iter++) begin
                  if (bytes_to_xgmii_ctrl[iter] != I_CONTROL) begin
                     candidate_t_blk_type = E_BLOCK;
                     break;
                  end
               end
            end
            else begin
               for (int iter=0; iter<7; iter++) begin
                  //if (bytes_to_xgmii_control[iter] != I_control) begin
                  if (!(bytes_to_xgmii_ctrl[iter] inside  {I_CONTROL, E_CONTROL})) begin
                     candidate_t_blk_type = E_BLOCK;
                     break;
                  end
               end
            end

         end
         // update the block format
         if (candidate_t_blk_type == T_BLOCK) m_current_blk_format = 8;
         else if (candidate_t_blk_type == C_BLOCK) m_current_blk_format = 1;
      end else if ({a_tx_c0,a_tx_c1} == 8'hF8) begin
         //check cases : CCCC/ODDD - both idle and error allowed
         //              CCCC/SDDD - both idle and error allowed
         // initialize to first case, C_block
         candidate_t_blk_type = C_BLOCK;
         for (int iter=0; iter<8; iter++) begin
            if (iter >= 4) begin
               //if (bytes_to_xgmii_control[iter] != I_control)  begin
               if (!(bytes_to_xgmii_ctrl[iter] inside  {I_CONTROL, E_CONTROL})) begin
                  candidate_t_blk_type = E_BLOCK;
               end
            end
            else if (iter == 3) begin
               candidate_t_blk_type = (bytes_to_xgmii_ctrl[iter] == Q_CONTROL) ?
               C_BLOCK : ((bytes_to_xgmii_ctrl[iter] == S_CONTROL) ? S_BLOCK : E_BLOCK);
            end

            if (candidate_t_blk_type == E_BLOCK) break;
         end
         // update the block format
         if (candidate_t_blk_type == S_BLOCK) m_current_blk_format = 3;
         else if (candidate_t_blk_type == C_BLOCK) m_current_blk_format = 2;
      end else if ({a_tx_c0,a_tx_c1} == 8'h8F) begin
         // check case : ODDD/CCCC - both idle and error allowed
         for (int iter=0; iter<8; iter++) begin
            if (iter < 4) begin
               //if (bytes_to_xgmii_control[iter] != I_control)  begin
               if (!(bytes_to_xgmii_ctrl[iter] inside  {I_CONTROL, E_CONTROL})) begin
                  candidate_t_blk_type = E_BLOCK;
               end
            end
            else if (iter == 7) begin
               candidate_t_blk_type = (bytes_to_xgmii_ctrl[iter] == Q_CONTROL) ? C_BLOCK : E_BLOCK;
            end

            if (candidate_t_blk_type == E_BLOCK) break;
         end
         // update the block format
         if (candidate_t_blk_type == C_BLOCK) m_current_blk_format = 7;
      end else if ({a_tx_c0,a_tx_c1} == 8'h88) begin
         // check cases : ODDD/SDDD
         //             : ODDD/ODDD
         if (bytes_to_xgmii_ctrl[7] != Q_CONTROL) begin
            candidate_t_blk_type = E_BLOCK;
         end
         if(candidate_t_blk_type != E_BLOCK) begin
            candidate_t_blk_type = (bytes_to_xgmii_ctrl[3] == Q_CONTROL) ?
            C_BLOCK : ((bytes_to_xgmii_ctrl[3] == S_CONTROL) ? S_BLOCK : E_BLOCK);
         end
         // update the block format
         if (candidate_t_blk_type == C_BLOCK) m_current_blk_format = 5;
         else if (candidate_t_blk_type == S_BLOCK) m_current_blk_format = 4;
      end else if ({a_tx_c0,a_tx_c1} == 8'h80) begin
         // check case : SDDD/DDDD
         // initiate to probable t_block_type
         candidate_t_blk_type =  S_BLOCK;
         if (bytes_to_xgmii_ctrl[7] != S_CONTROL) begin
            candidate_t_blk_type = E_BLOCK;
         end
         // update the block format
         if (candidate_t_blk_type == S_BLOCK) m_current_blk_format = 6;
      end else if ({a_tx_c0,a_tx_c1} inside { 8'h7F, 8'h3F, 8'h1F, 8'h0F, 8'h07, 8'h03, 8'h01 }) begin
         //find highest position holding a '1'
         bit [2:0] highest_one_pos;
         tx_c_both = {a_tx_c0,a_tx_c1};
         for (int iter=7; iter>=0; iter--) begin
            if (tx_c_both[iter] == 1)   begin
               highest_one_pos = iter;
               break;
            end
         end
         // initiate to probable t_block_type
         candidate_t_blk_type = T_BLOCK;
         // check cases : DTCC/CCCC DDTC/CCCC DDDT/CCCC DDDD/TCCC DDDD/DTCC DDDD/DDTC DDDD/DDDT - both idle and error
         for (int iter=0; iter<8; iter++) begin
            if (iter == highest_one_pos) begin
               if (bytes_to_xgmii_ctrl[iter] != T_CONTROL) begin
                  candidate_t_blk_type = E_BLOCK;
               end
            end
            else if (iter < highest_one_pos) begin
               //if (bytes_to_xgmii_control[iter] != I_control) begin
               if (!(bytes_to_xgmii_ctrl[iter] inside  {I_CONTROL, E_CONTROL})) begin
                  candidate_t_blk_type = E_BLOCK;
               end
            end
         end
         // update the block format
         if (candidate_t_blk_type == T_BLOCK) m_current_blk_format = 8 + 7 - highest_one_pos ;
      end
      else begin
         candidate_t_blk_type = E_BLOCK;
      end;

      return candidate_t_blk_type;

   endfunction


   /* Function that returns the type of a byte
    * @param a_code_byte_in : the byte that is part of the xgmii data bus
    * @param a_byte_type    : one bit indicating is it's data or control byte,
    *                      taken from the correspondent position in inside tx_c0 or tx_c1 xgmii inputs
    */
   local function endec_64b66b_xgmii_control_code_e control_byte_to_control_type (
         bit[7:0] a_code_byte_in,
         bit a_byte_type
      );
      if (a_byte_type ==1) begin
         case (a_code_byte_in)
            8'h07: return I_CONTROL;
            8'hfb: return S_CONTROL;
            8'hfd: return T_CONTROL;
            8'hfe: return E_CONTROL;
            8'h9c: return Q_CONTROL;
            default: return NON_CONTROL;
         endcase
      end else begin
         return NON_CONTROL;
      end
   endfunction


   /* Transmit state machine
    * states : TX_INIT, TX_C, TX_D, TX_T, TX_E
    * @param a_xgmii_in : 2 xgmii transfers with format {tx_c1, tx_data1, tx_c0, tx_data0}
    * @return the coded 66bits block
    */
   virtual function bit [65:0] encode (bit[71:0] a_xgmii_in);
      // concatenation of data inputs
      bit[63:0] a_blk_format_data_in = {a_xgmii_in[31:0], a_xgmii_in[67:36]};
      // control/data indicators
      bit[3:0] a_tx_c1 = a_xgmii_in[71:68];
      bit[3:0] a_tx_c0 = a_xgmii_in[35:32];

      // this call updates the "current_block_format" field that will be used for encoding
      m_current_t_blk_type = xgmii_bytes_to_block_t_block_type (a_blk_format_data_in, a_tx_c0, a_tx_c1);


      `uvm_info("ENCODER_64b66b", $sformatf("\Current block type %s " , m_current_t_blk_type), UVM_MEDIUM)

      m_prev_transmit_state = m_transmit_state;

      case (m_transmit_state)
         TX_INIT: m_transmit_state = (m_current_t_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            TX_E : ((m_current_t_blk_type == C_BLOCK) ? TX_C : TX_D);
         TX_C   : m_transmit_state = (m_current_t_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            TX_E : ((m_current_t_blk_type == C_BLOCK) ? TX_C : TX_D);
         TX_D   : m_transmit_state = (m_current_t_blk_type inside {E_BLOCK, C_BLOCK, S_BLOCK}) ?
            TX_E : ((m_current_t_blk_type == D_BLOCK) ? TX_D : TX_T);
         TX_T   : m_transmit_state = (m_current_t_blk_type inside {E_BLOCK, D_BLOCK, T_BLOCK}) ?
            TX_E : ((m_current_t_blk_type == S_BLOCK) ? TX_D : TX_C);
         TX_E   : m_transmit_state = (m_current_t_blk_type inside {E_BLOCK, S_BLOCK}) ?
            TX_E : ((m_current_t_blk_type == C_BLOCK) ? TX_C : ((m_current_t_blk_type == D_BLOCK) ? TX_D : TX_T));
      endcase

      // print current transmit state
      `uvm_info("ENCODER_64b66b", $sformatf("Current state of the transmit state machine is  %s", m_transmit_state),
         UVM_MEDIUM)

      //encoder_cov_data = new();
      m_enc_cov_data = endec_64b66b_encoder_cov_c::type_id::create("m_enc_cov_data");

      // set the output based on the transition
      if (m_transmit_state inside {TX_C, TX_D, TX_T}) begin
         if (m_first_sample_done) begin
            m_prev_tx_blk_format = m_tx_blk_format;
         end

         m_tx_blk_format = endec_64b66b_block_formats_e'(m_current_blk_format);

         m_enc_cov_data.m_tx_blk_format = m_tx_blk_format;
         m_enc_cov_data.m_prev_tx_blk_format = m_prev_tx_blk_format;
         m_enc_cov_data.m_first_sample_done = m_first_sample_done;
         m_enc_cov_data.m_tx_blk_formats_sampled = 1;

         m_first_sample_done = 1;
      end

      m_enc_cov_data.m_transmit_state = m_transmit_state;

      m_data_to_cov_ap.write(m_enc_cov_data);

      if (m_transmit_state inside {TX_C, TX_D, TX_T}) begin
         return build_block_payload (a_blk_format_data_in);
      end else begin
         return `T_EBLOCK_T;
      end

   endfunction


   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      m_data_to_cov_ap.connect(m_encoder_cov.m_get_data_to_cov_ai);
   endfunction


   /* Implements figure 49-7 64B/66B block formats
    * array below excludes the header, the 4 bits entry
    * selects the format
    * @param a_blk_format_data_in : concatenation of the two xgmii input transfers data
    * @return encoded block
    */
   local function bit [65:0] build_block_payload (bit[63:0] a_blk_format_data_in); // this is actually the encode function
      bit [65:0] block_payload;
      bits7_unpacked_arr ctrl_code_10gbaseR;
      bit [63:0] ctrl_code_10gbaseR_concatenated;


      // prepare the control characters conversion to be used in the encoding process
      case (m_current_blk_format)
         // D0|D1|D2|D3|D4|D5|D6|D7
         0 : ctrl_code_10gbaseR = '{0};//VCS asks for this {};
         // C0|C1|C2|C3|C4|C5|C6|C7
         1 : ctrl_code_10gbaseR = '{0};//VCS asks for this {};//only idles are allowed
         // C0|C1|C2|C3|O4|D5|D6|D7
         2 : ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[63:56],
                  a_blk_format_data_in[55:48],a_blk_format_data_in[47:40],a_blk_format_data_in[39:32]});//can be idle or error
         // C0|C1|C2|C3|||||D5|D6|D7
         3 : ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[63:56],
                  a_blk_format_data_in[55:48],a_blk_format_data_in[47:40],a_blk_format_data_in[39:32]});//can be idle or error
         // D1|D2|D3|O0|||||D5|D6|D7
         4 : ctrl_code_10gbaseR = '{0};//VCS asks for this {};
         // D1|D2|D3|O0|O4|D5|D6|D7
         5 : ctrl_code_10gbaseR = '{0};//VCS asks for this {};
         // D1|D2|D3|D4|D5|D6|D7
         6 : ctrl_code_10gbaseR = '{0};//VCS asks for this {};
         // D1|D2|D3|O0|C4|C5|C6|C7
         7 : ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[31:24],
                  a_blk_format_data_in[23:16],a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // ||||||||C1|C2|C3|C4|C5|C6|C7
         8 : ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[55:48],
                  a_blk_format_data_in[47:40],a_blk_format_data_in[39:32],a_blk_format_data_in[31:24],
                  a_blk_format_data_in[23:16],a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // D0|||||||C2|C3|C4|C5|C6|C7
         9 : ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[47:40],
                  a_blk_format_data_in[39:32],a_blk_format_data_in[31:24],a_blk_format_data_in[23:16],
                  a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1||||||C3|C4|C5|C6|C7
         10: ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[39:32],
                  a_blk_format_data_in[31:24],a_blk_format_data_in[23:16],
                  a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1|D2|||||C4|C5|C6|C7
         11: ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[31:24],
                  a_blk_format_data_in[23:16],a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1|D2|D3||||C5|C6|C7
         12: ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[23:16],
                  a_blk_format_data_in[15:8],a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1|D2|D3|D4|||C6|C7
         13: ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[15:8],
                  a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1|D2|D3|D4|D5||C7
         14: ctrl_code_10gbaseR = xgmii_c_codes_to_10gbaseR_c_codes('{a_blk_format_data_in[7:0]});//can be idle or error
         // D0|D1|D2|D3|D4|D5|D6
         15: ctrl_code_10gbaseR = '{0};//VCS asks for this {};
      endcase


      // concatenate the result
      foreach(ctrl_code_10gbaseR[iter]) begin
         ctrl_code_10gbaseR_concatenated = {ctrl_code_10gbaseR_concatenated,ctrl_code_10gbaseR[iter]};
      end


      case (m_current_blk_format)
         // D0|D1|D2|D3|D4|D5|D6|D7
         0 : block_payload = {2'b01,a_blk_format_data_in};
         // C0|C1|C2|C3|C4|C5|C6|C7
         1 : block_payload = {2'b10,BLK_TYPE_0,{8{7'b0}}};//only idles are allowed
         // C0|C1|C2|C3|O4|D5|D6|D7
         2 : block_payload = {2'b10,BLK_TYPE_1,ctrl_code_10gbaseR_concatenated[27:0],4'b0,a_blk_format_data_in[23:0]};//can be idle or error
         // C0|C1|C2|C3|||||D5|D6|D7
         3 : block_payload = {2'b10,BLK_TYPE_2,ctrl_code_10gbaseR_concatenated[27:0],4'b0,a_blk_format_data_in[23:0]};//can be idle or error
         // D1|D2|D3|O0|||||D5|D6|D7
         4 : block_payload = {2'b10,BLK_TYPE_3,a_blk_format_data_in[55:32],4'b0,4'b0,a_blk_format_data_in[23:0]};
         // D1|D2|D3|O0|O4|D5|D6|D7
         5 : block_payload = {2'b10,BLK_TYPE_4,a_blk_format_data_in[55:32],4'b0,4'b0,a_blk_format_data_in[23:0]};
         // D1|D2|D3|D4|D5|D6|D7
         6 : block_payload = {2'b10,BLK_TYPE_5,a_blk_format_data_in[55:0]};
         // D1|D2|D3|O0|C4|C5|C6|C7
         7 : block_payload = {2'b10,BLK_TYPE_6,a_blk_format_data_in[55:32],4'b0,ctrl_code_10gbaseR_concatenated[27:0]};//can be idle or error
         // ||||||||C1|C2|C3|C4|C5|C6|C7
         8 : block_payload = {2'b10,BLK_TYPE_7,7'b0,ctrl_code_10gbaseR_concatenated[48:0]};//can be idle or error
         // D0|||||||C2|C3|C4|C5|C6|C7
         9 : block_payload = {2'b10,BLK_TYPE_8,a_blk_format_data_in[63:56],6'b0,ctrl_code_10gbaseR_concatenated[41:0]};//can be idle or error
         // D0|D1||||||C3|C4|C5|C6|C7
         10: block_payload = {2'b10,BLK_TYPE_9,a_blk_format_data_in[63:48],5'b0,ctrl_code_10gbaseR_concatenated[34:0]};//can be idle or error
         // D0|D1|D2|||||C4|C5|C6|C7
         11: block_payload = {2'b10,BLK_TYPE_10,a_blk_format_data_in[63:40],4'b0,ctrl_code_10gbaseR_concatenated[27:0]};//can be idle or error
         // D0|D1|D2|D3||||C5|C6|C7
         12: block_payload = {2'b10,BLK_TYPE_11,a_blk_format_data_in[63:32],3'b0,ctrl_code_10gbaseR_concatenated[20:0]};//can be idle or error
         // D0|D1|D2|D3|D4|||C6|C7
         13: block_payload = {2'b10,BLK_TYPE_12,a_blk_format_data_in[63:24],2'b0,ctrl_code_10gbaseR_concatenated[13:0]};//can be idle or error
         // D0|D1|D2|D3|D4|D5||C7
         // 14: block_payload = {2'b10,8'he1,block_format_data_in[63:16],1'b0,{7'b0}};//can be idle or error
         14: block_payload = {2'b10,BLK_TYPE_13,a_blk_format_data_in[63:16],1'b0,ctrl_code_10gbaseR_concatenated[6:0]};//can be idle or error
         // D0|D1|D2|D3|D4|D5|D6
         15: block_payload = {2'b10,BLK_TYPE_14,a_blk_format_data_in[63:8]};
      endcase


      return block_payload;
   endfunction


   /* Function used to encode control characters from the xgmii data input
    * into 10GBASE-R control codes
    * @param a_xgmii_data_bytes : variable number of the 8 bytes that form the data of the  two xgmii transfers
    * @return unpacked array with the control codes in 10gbaseR format converted from the input xgmii bytes
    */
   local function bits7_unpacked_arr xgmii_c_codes_to_10gbaseR_c_codes (byte a_xgmii_data_bytes []);
      bits7_unpacked_arr ctrl_code_10gbaseR;

      ctrl_code_10gbaseR= new[a_xgmii_data_bytes.size()];
      foreach (a_xgmii_data_bytes[iter]) begin
         // expect only IDLE and ERROR characters here (0x07 and 0xfe)
         assert (a_xgmii_data_bytes[iter] inside {8'b00000111, 8'b11111110}) else
            `uvm_error("ENCODER_64b66b_ILLEGAL_CONTOL_CHARACTER_VALUE", "Only IDLE or ERROR characters expected here.")
         // fill array with IDLE/ERROR characters corresponding to the xgmii characters
         ctrl_code_10gbaseR[iter] = (a_xgmii_data_bytes[iter] == I_CONTROL) ? 7'b0 : 7'b11110;
      end

      return ctrl_code_10gbaseR;
   endfunction

endclass

`endif
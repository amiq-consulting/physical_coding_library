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
 * MODULE:      endec_8b10b_encoder.sv
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This is the implementation file of the 8b10b encoder that's
 *              part of endec_8b10b package
 *****************************************************************************/

`ifndef ENDEC_8b10b_ENCODER_SVH
`define ENDEC_8b10b_ENCODER_SVH


/* Encoder class
 * Receives the 8bit data input and outputs the corresponding 10bit
 * encoded symbol
 */
class endec_8b10b_encoder extends uvm_component;
   `uvm_component_utils(endec_8b10b_encoder)

   //holds the disparity throughout the encoding process, initial value is -1
   int m_running_disp;
   //control symbol or data symbol

   //holding the mappings used for encoding
   endec_8b10b_mappings m_mappings;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_cov_data) m_cov_data_analysis_port;
   //coverage collector
   endec_8b10b_coverage m_coverage_h;
   //coverage data class
   endec_8b10b_cov_data cov_data;


   /*constructor
    * @param name - name of the component instance
    * @param parent - parent of the component instance
    */
   function new(input string name, input uvm_component parent);
      super.new(name, parent);

      m_cov_data_analysis_port = new("m_cov_data_analysis_port", this);
      //set initial disparity
      m_running_disp = -1;
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      //create the coverage collector
      m_coverage_h = endec_8b10b_coverage::type_id::create("m_coverage_h", this);
      m_mappings = endec_8b10b_mappings::type_id::create("m_mappings");
      //create the coverage data class
      cov_data = endec_8b10b_cov_data::type_id::create("encoder_cov_data");
   endfunction

   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_cov_data_analysis_port.connect(m_coverage_h.m_cov_data_ap);
   endfunction

   /* Function to set the disparity
    * @param a_disparity_val - value assigned to initial running disparity
    */
   virtual function void set_disparity(int a_disparity_val);
      m_running_disp = a_disparity_val;
   endfunction


   /* Encoding function
    * @param   a_encode_in - struct containing data byte to be encoded
    * @return  encoded 10 bit symbol
    */
   virtual function bit [9:0] encode (endec_8b10b_enc_in_dec_out_s a_encode_in);
      bit [9:0] encoded_symbol;
      //coverage
      cov_data.m_data = a_encode_in.enc_dec_8b_val;
      cov_data.m_is_k_symbol = a_encode_in.is_k_symbol;
      cov_data.m_pre_disp = m_running_disp;
      //--------

      //check for illegal input; only possible illegal input is to have
      //the control symbol indication set and the 8bit value to encode to be
      //outside the legal control symbol values expressed on 8bits
      if (
            (a_encode_in.is_k_symbol == 1) &&
            !(a_encode_in.enc_dec_8b_val inside {K_28_0_8B, K_28_1_8B, K_28_2_8B, K_28_3_8B, K_28_4_8B,
                  K_28_5_8B, K_28_6_8B, K_28_7_8B, K_23_7_8B, K_27_7_8B, K_29_7_8B, K_30_7_8B} )
         )begin
         `uvm_fatal(
            "ENDEC_8b10b_ENCODER",
            "Input control symbol indication set but the 8bit value is not among the control symbols."
         )
      end

      encoded_symbol =
      (a_encode_in.is_k_symbol == 1) ?
      gen_encoded_10bit_control_symbol(a_encode_in)
      :
      gen_encoded_10bit_data_symbol(a_encode_in);



      `uvm_info(
         "ENCODER_8b10b",
         $sformatf(
            "\nEncoded %s symbol is %10b, new disparity is %1d",
            (a_encode_in.is_k_symbol == 1) ? "control" : "data",
            encoded_symbol,
            m_running_disp
         ),
         UVM_HIGH)

      //report coverage data including the disparity
      //coverage
      cov_data.m_encoded_symb = encoded_symbol;
      cov_data.m_post_disp = m_running_disp;
      //no errors allowed from the encoder
      m_cov_data_analysis_port.write(cov_data);
      //--------

      return encoded_symbol;
   endfunction

   /* Output the 6 bits code based on the 5 bits of data byte to be encoded
    * @param a_data_byte_5lsb - 5 lsb of the data byte to be encoded
    * @return the 6bit encoded value of the 5bit input with respect the the
    * current running disparity
    */
   virtual function bit [5:0] to_encoded_6_bits_data (input bit [4:0] a_data_byte_5lsb);
      endec_8b10b_d_6b_e code_symbol_6b;
      bit[6:0] map_entry;
      bit [1:0] running_disp_in = (m_running_disp == -1) ? 0 : 1;
      map_entry = (running_disp_in<<5) + a_data_byte_5lsb;

      code_symbol_6b = m_mappings.m_map_to_5b6b[map_entry];
      //update the disparity
      //handle special cases when encoded symbol value is '000111' or '111000'
      if (code_symbol_6b == 6'b000111) begin
         m_running_disp = 1;
      end
      else if (code_symbol_6b == 6'b111000) begin
         m_running_disp = -1;
      end
      else begin
         //code symbol disparity from array
         m_running_disp += (m_mappings.m_map_from_5b6b[code_symbol_6b][6:5] == 0) ? -2 :
         ((m_mappings.m_map_from_5b6b[code_symbol_6b][6:5] == 1) ? 0 : 2);
      end

      return code_symbol_6b;
   endfunction

   /* Output the 3b4b encoded word corresponding to the 3 msb of the input
    * data byte
    * @param a_data_byte_3msb - 3 msb of the data byte to be encoded
    * @param a_data_byte_5lsb - 5 lsb of the data byte to be encoded
    * @return the 4bit encoded value of the 3 msb input with respect to
    * the current running disparity
    */
   virtual function bit [3:0] to_encoded_4_bits_data (input bit [2:0] a_data_byte_3msb, input bit [4:0] a_data_byte_5lsb);//last parameter needed for encoding raw data value '7'
      endec_8b10b_d_4b_e code_symbol_4b;
      bit[5:0] map_entry;
      bit[1:0] running_disp_in = (m_running_disp == -1) ? 0 : 1;

      if (
            ((a_data_byte_5lsb inside {17, 18, 20}) && (m_running_disp == -1) && (a_data_byte_3msb == 7)) ||
            ((a_data_byte_5lsb inside {11, 13, 14}) && (m_running_disp == 1) && (a_data_byte_3msb == 7))
         ) begin
         map_entry = (running_disp_in<<4) + 8;//alternative encoding for data '7'
      end
      else begin
         map_entry = (running_disp_in<<4) + a_data_byte_3msb;
      end

      code_symbol_4b = m_mappings.m_map_to_3b4b[map_entry];

      //update the disparity
      //handle special cases when encoded symbol value is '0011' or '1100'
      if (code_symbol_4b == 4'b0011) begin
         m_running_disp = 1;
      end
      else if (code_symbol_4b == 4'b1100) begin
         m_running_disp = -1;
      end
      else begin
         m_running_disp += (m_mappings.m_map_from_3b4b[code_symbol_4b][5:4] == 0) ? -2 :
         ((m_mappings.m_map_from_3b4b[code_symbol_4b][5:4] == 1) ? 0 : 2);
      end

      return code_symbol_4b;
   endfunction

   /* Function to generate encoded 10bit data symbol
    * @param a_data_to_encode - struct with data byte to encode
    * @return  10b value of coded symbol
    */
   virtual function bit [9:0]  gen_encoded_10bit_data_symbol (input endec_8b10b_enc_in_dec_out_s a_data_to_encode);
      bit [9:0] coded_symb_bits;

      if (!((m_running_disp ==-1) || (m_running_disp == 1))) begin
         `uvm_fatal("ENDEC_8b10b_ENCODER_RUNNING_DISPARITY_ERR", "Disparity has invalid value.")
      end

      coded_symb_bits[9:4] = to_encoded_6_bits_data(a_data_to_encode.enc_dec_8b_val[4:0]);

      coded_symb_bits[3:0] = to_encoded_4_bits_data(
         a_data_to_encode.enc_dec_8b_val[7:5],
         a_data_to_encode.enc_dec_8b_val[4:0]
      );


      return coded_symb_bits;
   endfunction

   //Functionality related to control symbol encoding

   /* Output the 6 bits code corresponding to the 5 bits of data byte
    * to be encoded as a control symbol
    * @param a_data_byte_5lsb - 5 lsb of the data byte to be encoded
    * @return the 6bit encoded value of the 5bit input with respect to the
    * current running disparity
    */
   virtual function bit [5:0] to_encoded_6_bits_control (input bit [4:0] a_data_byte_5lsb);
      endec_8b10b_k_6b_e encoded_k_6b;
      bit[6:0] map_key;
      bit[1:0] running_disp_in = (m_running_disp == -1) ? 0 : 1;
      map_key = (running_disp_in<<5) + a_data_byte_5lsb;

      if (!m_mappings.m_map_to_k_6b.exists(map_key)) begin
         `uvm_fatal("ENDEC_8b10b_ENCODER_INVALID_K_SYMBOL_ERR",
            "Input data to encode is not valid for control symbol.")
      end
      encoded_k_6b = m_mappings.m_map_to_k_6b[map_key];

      //update running disparity
      m_running_disp += (m_mappings.m_map_from_k_6b[encoded_k_6b][6:5] == 0) ? -2 :
      ((m_mappings.m_map_from_k_6b[encoded_k_6b][6:5] == 1) ? 0 : 2);

      return encoded_k_6b;
   endfunction

   /* Output the 4 bits code corresponding to the 3 msb of input data byte
    * to be encoded as a control symbol
    * @param a_data_byte_3msb - 3 msb of the data byte to be encoded
    * @return the 4bit encoded word corresponding to the 3 msb of the data byte
    * to be encoded
    */
   virtual function bit [3:0] to_encoded_4_bits_control (input bit [2:0] a_data_byte_3msb);
      bit[5:0] map_key;
      bit[1:0] running_disp_in = (m_running_disp == -1) ? 0 : 1;
      map_key = (running_disp_in<<4) + a_data_byte_3msb;

      if (m_running_disp == -1) begin
         endec_8b10b_k_4b_n_e k_symbol_4b;
         k_symbol_4b = m_mappings.m_map_to_k_4b_n[map_key];

         //update running disparity
         //special condition in the running disparity calculation -> if encoded symbol is '1100' disparity is negative
         if (a_data_byte_3msb == 3) begin
            m_running_disp = -1;
         end
         else begin
            m_running_disp += (m_mappings.m_map_from_k_4b_n[k_symbol_4b][5:4] == 0) ? -2 :
            ((m_mappings.m_map_from_k_4b_n[k_symbol_4b][5:4] == 1) ? 0 : 2);
         end

         return k_symbol_4b;
      end else begin
         endec_8b10b_k_4b_p_e k_symbol_4b;
         k_symbol_4b = m_mappings.m_map_to_k_4b_p[map_key];

         //update running disparity
         //special condition in the running disparity calculation -> if encoded symbol is '0011' disparity is positive
         if (a_data_byte_3msb == 3) begin
            m_running_disp = 1;
         end
         else begin
            m_running_disp += (m_mappings.m_map_from_k_4b_p[k_symbol_4b][5:4] == 0) ? -2 :
            ((m_mappings.m_map_from_k_4b_p[k_symbol_4b][5:4] == 1) ? 0 : 2);
         end

         return k_symbol_4b;
      end
   endfunction

   /* Function to generate encoded 10bit control symbol
    * @param a_data_to_encode - struct with the data byte to encode
    * @return the 10b value of coded symbol
    */
   virtual function  bit [9:0] gen_encoded_10bit_control_symbol (input endec_8b10b_enc_in_dec_out_s a_data_to_encode);
      bit [9:0] coded_symb_bits;
      //check received 8bit value is valid
      endec_8b10b_k_8b_e k_symbol_8b;

      //check running disparity to be valid
      if (!((m_running_disp ==-1) || (m_running_disp == 1))) begin
         `uvm_fatal("ENDEC_8b10b_ENCODER_RUNNING_DISPARITY_ERR", "Disparity has invalid value.")
      end

      k_symbol_8b = k_symbol_8b.first();
      forever begin
         if (k_symbol_8b == a_data_to_encode.enc_dec_8b_val) begin
            //call here function that returns correct control symbol
            coded_symb_bits[9:4] = to_encoded_6_bits_control(a_data_to_encode.enc_dec_8b_val[4:0]);
            coded_symb_bits[3:0] = to_encoded_4_bits_control(a_data_to_encode.enc_dec_8b_val[7:5]);
            break;
         end
         if (k_symbol_8b == k_symbol_8b.last()) begin
            `uvm_fatal("ENDEC_8b10b_ENCODER_K_8B_INPUT_ERR", "Input data to encode is not valid for control symbol.")
            break;
         end
         k_symbol_8b = k_symbol_8b.next();
      end


      return coded_symb_bits;
   endfunction

endclass

`endif//ENDEC_8b10b_ENCODER_SVH
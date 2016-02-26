`ifndef ENDEC_8b10b_DECODER_SVH
`define ENDEC_8b10b_DECODER_SVH


/* Decoder class
 * Receives 10bit encoded symbol, decodes it and outputs the decoded result
 */
class endec_8b10b_decoder extends uvm_component;
   `uvm_component_utils(endec_8b10b_decoder)


   //struct type declarations used only in this class
   //struct holding a flag to signal if it contains a control symbol
   //and a field holding the control symbol
   typedef struct  {
      bit is_k_symbol = 0;
      endec_8b10b_k_10b_e k_symbol_10b;
   } endec_8b10b_has_k_symbol_s;


   //struct holding the output of the function returning the
   //decoded 3b4b symbol and the error indication if any
   typedef struct  {
      bit [2:0] decode_3b4b_val;
      bit [1:0] decode_err;
   } endec_8b10b_3b4b_decode_s;


   //struct holding the output of the function returning the
   //decoded 5b6b symbol and the error indication if any
   typedef struct  {
      bit [4:0] decode_5b6b_val;
      bit [1:0] decode_err;
   } endec_8b10b_5b6b_decode_s;


   //holds the disparity throughout the encoding process, initial value is -1
   int m_running_disp;

   //holds the mappings used for decoding
   endec_8b10b_mappings m_mappings;

   // Analysis ports to report items to other components
   uvm_analysis_port #(endec_8b10b_cov_data) m_cov_data_analysis_port;
   //coverage collector
   endec_8b10b_coverage m_coverage_h;
   //coverage data class
   endec_8b10b_cov_data cov_data;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
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
      cov_data = endec_8b10b_cov_data::type_id::create("decoder_cov_data");
   endfunction

   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      m_cov_data_analysis_port.connect(m_coverage_h.m_cov_data_ap);
   endfunction

   /* Function to set the disparity
    * @param a_disparity_val - value assigned to initial running disparity
    */
   virtual function void set_disparity(int a_disparity_val);
      m_running_disp = a_disparity_val;
   endfunction


   /* Decode function
    * @param a_coded_symbol -  the encoded symbol
    */
   virtual function endec_8b10b_enc_in_dec_out_s decode (input bit [9:0] a_coded_symbol);
      //decode received data
      endec_8b10b_enc_in_dec_out_s decode_out;
      //coverage
      cov_data.m_encoded_symb = a_coded_symbol;
      cov_data.m_pre_disp = m_running_disp;
      //--------


      decode_out = decode_8b10b_symbol(a_coded_symbol);
      if (decode_out.decode_err != 0) begin
         //set disparity to known state
         set_disparity(-1);
      end

      //report coverage data including the disparity
      //coverage
      cov_data.m_data = decode_out.enc_dec_8b_val;
      cov_data.m_is_k_symbol = decode_out.is_k_symbol;
      cov_data.m_post_disp = m_running_disp;
      //send coverage data
      m_cov_data_analysis_port.write(cov_data);
      //--------

      //output the decoded value
      return decode_out;
   endfunction

   /* Function that detects if the symbol received  is a control symbol
    * @param a_coded_symbol - 10b coded symbol
    * @return struct containing a field set if a control symbol was detected
    * and another field with the detected symbol name
    */
   virtual function endec_8b10b_has_k_symbol_s find_symbol_type (input bit [9:0] a_coded_symbol);
      endec_8b10b_has_k_symbol_s  k_symbol_s;
      endec_8b10b_k_10b_e k_symbol = k_symbol.first();
      // variable used to stop the search when reached last symbol
      //set depending on type of symbols searched(positive or negative disparity)
      endec_8b10b_k_10b_e stop_k_symbol;

      if (m_running_disp == -1) begin
         //set stop symbol to last negative disparity symbol
         stop_k_symbol = stop_k_symbol.last();
         stop_k_symbol = stop_k_symbol.prev();
         forever begin
            if (k_symbol == a_coded_symbol) begin
               k_symbol_s = '{1,k_symbol};
               break;
            end
            if (k_symbol == stop_k_symbol) begin
               break;
            end
            k_symbol = k_symbol.next(2);
         end
      end else begin
         if (m_running_disp == 1) begin
            //set stop symbol to last positive disparity symbol
            stop_k_symbol = stop_k_symbol.last();
            //move to first value with positive disparity encoding
            k_symbol = k_symbol.next();
            forever begin
               if (k_symbol == a_coded_symbol) begin
                  k_symbol_s = '{1,k_symbol};
                  break;
               end
               if (k_symbol == stop_k_symbol) begin
                  break;
               end
               k_symbol = k_symbol.next(2);
            end
         end
      end

      return k_symbol_s;
   endfunction


   /* Function that receives the 10bit encoded symbol and returns the value
    *  of the decoded data if it's a data symbol
    * @param a_coded_symbol - 10b coded symbol
    * @return struct containing the error indication, the data/control symbol
    *  indication, the decoded symbol(if no error)
    */
   virtual function endec_8b10b_enc_in_dec_out_s decode_8b10b_symbol (input bit [9:0] a_coded_symbol);
      // variable to checking for k symbol
      endec_8b10b_has_k_symbol_s check_k_symbol;

      //variable for output
      endec_8b10b_enc_in_dec_out_s out_s;

      //variables holding intermediary results
      endec_8b10b_3b4b_decode_s out_decode_3b4b;
      endec_8b10b_5b6b_decode_s out_decode_5b6b;


      check_k_symbol = find_symbol_type (a_coded_symbol);
      out_s.is_k_symbol = check_k_symbol.is_k_symbol;

      `uvm_info(
         "DECODER_8b10b",
         $sformatf(
            "\nReceived coded %s symbol %10b with current disparity %1d",
            (check_k_symbol.is_k_symbol == 1) ? "control" : "data", a_coded_symbol, m_running_disp
         ),
         UVM_HIGH
      )

      out_decode_5b6b = (check_k_symbol.is_k_symbol == 0) ? decode_5b6b_d_symbol(a_coded_symbol[9:4]) :
      decode_5b6b_c_symbol(a_coded_symbol[9:4]);

      if (out_decode_5b6b.decode_err == 0) begin
         out_s.enc_dec_8b_val[4:0] = out_decode_5b6b.decode_5b6b_val;
         out_decode_3b4b = (check_k_symbol.is_k_symbol == 0) ? decode_3b4b_d_symbol(a_coded_symbol[3:0]) :
         decode_3b4b_c_symbol(a_coded_symbol[3:0]);

         if (out_decode_3b4b.decode_err == 0) begin
            out_s.enc_dec_8b_val[7:5] = out_decode_3b4b.decode_3b4b_val;
         end else begin
            out_s.decode_err = out_decode_3b4b.decode_err;
         end
      end
      else begin
         out_s.decode_err = out_decode_5b6b.decode_err;
      end

      if (out_s.decode_err == 0) begin
         `uvm_info(
            "DECODER_8b10b",
            $sformatf("\nDecoded data             %x", out_s.enc_dec_8b_val),
            UVM_HIGH
         )
      end else begin
         `uvm_info(
            "DECODER_8b10b",
            $sformatf("\nCurrent decode cycle ended with %s",
               out_s.decode_err == 1 ? "DISPARITY_ERROR" : "SYMBOL_ERROR"
            ),
            UVM_HIGH
         )
      end

      return out_s;
   endfunction


   /* Functions to decode the data symbols
    * these functions work on data symbols only
    * @param a_coded_symb_6b - 5b6b code word to be decoded
    * @return struct containing the decoder bits and the error status
    */
   virtual function endec_8b10b_5b6b_decode_s decode_5b6b_d_symbol (input bit [5:0] a_coded_symb_6b);
      endec_8b10b_d_6b_e d_symbol_6b;
      bit[6:0] map_out;
      int code_word_disp;
      endec_8b10b_5b6b_decode_s out_s;

      if ((m_running_disp !=-1) && (m_running_disp != 1)) begin
         out_s.decode_err = 1;//disparity error
      end
      else begin
         if (!m_mappings.m_map_from_5b6b.exists(a_coded_symb_6b)) begin
            //type of error is symbol error
            out_s.decode_err = 2;//symbol error
         //no more decoding since 6b code word is corrupt
         end else begin
            d_symbol_6b = endec_8b10b_d_6b_e'(a_coded_symb_6b);

            `uvm_info("DECODER_8b10b",$sformatf("Decoded 5b6b data symbol is %s ", d_symbol_6b.name()), UVM_HIGH)

            map_out = m_mappings.m_map_from_5b6b[d_symbol_6b];
            //get 5b6b coded word disparity based on the representation(0->-2, 1->0, 2->2)
            code_word_disp = (map_out[6:5] == 0) ? -2 : ((map_out[6:5] == 1) ? 0 : 2);

            out_s.decode_5b6b_val = map_out[4:0];
            //check and update disparity
            //handle special cases when encoded symbol value is '000111' or '111000'
            if (d_symbol_6b == 6'b000111) begin
               m_running_disp = 1;
            end
            else if (d_symbol_6b == 6'b111000) begin
               m_running_disp = -1;
            end
            else begin

               if (code_word_disp != m_running_disp) begin
                  //calculate new disparity
                  m_running_disp += code_word_disp;
               end else begin
                  out_s.decode_err = 1;//disparity error
               end
            end
         end
      end

      return out_s;
   endfunction


   /* This function works on data symbols only
    * @param a_coded_symb_4b - 3b4b code word to be decoded
    * @return struct containing the decoder bits and the error status
    */
   virtual function endec_8b10b_3b4b_decode_s decode_3b4b_d_symbol (input bit [3:0] a_coded_symb_4b);
      endec_8b10b_d_4b_e data_symbol_4b;
      bit[5:0] map_out;
      int code_word_disp;
      endec_8b10b_3b4b_decode_s out_s;


      if ((m_running_disp !=-1) && (m_running_disp != 1)) begin
         out_s.decode_err = 1;//disparity error
      end
      else begin
         if (!m_mappings.m_map_from_3b4b.exists(a_coded_symb_4b)) begin
            //type of error is symbol error
            out_s.decode_err = 2;//symbol error
         //no more decoding since 6b code word is corrupt
         end else begin
            data_symbol_4b = endec_8b10b_d_4b_e'(a_coded_symb_4b);

            `uvm_info("DECODER_8b10b",$sformatf("Decoded 3b4b data symbol is %s ", data_symbol_4b.name()), UVM_HIGH)

            map_out = m_mappings.m_map_from_3b4b[data_symbol_4b];
            //get 3b4b coded word disparity based on the representation(0->-2, 1->0, 2->2)
            code_word_disp = (map_out[5:4] == 0) ? -2 : ((map_out[5:4] == 1) ? 0 : 2);

            out_s.decode_3b4b_val = (map_out[3:0] == 8) ? 7 : map_out[3:0];
            //check and update disparity
            //handle special cases when encoded symbol value is '0011' or '1100'
            if (data_symbol_4b == 4'b0011) begin
               m_running_disp = 1;
            end
            else if (data_symbol_4b == 4'b1100) begin
               m_running_disp = -1;
            end
            else  begin

               if (code_word_disp != m_running_disp) begin
                  //calculate new disparity
                  m_running_disp += code_word_disp;
               end else begin
                  out_s.decode_err = 1;//disparity error
               end
            end
         end
      end

      return out_s;
   endfunction


   // Functions to decode the control symbols


   /* Function to decode the 5b6b coded symbol
    * @param a_code_symbol_6b - 5b6b encoded symbol
    * @return struct containing the decoded bits and the error status
    */
   virtual function endec_8b10b_5b6b_decode_s decode_5b6b_c_symbol (input bit [5:0] a_code_symbol_6b);
      endec_8b10b_k_6b_e control_symb_6b;
      bit[6:0] map_out;
      int code_word_disp;
      endec_8b10b_5b6b_decode_s out_s;


      if ((m_running_disp !=-1) && (m_running_disp != 1)) begin
         out_s.decode_err = 1;//disparity error
      // no more decoding because of error
      end
      else begin
         //look for the symbol in the map
         if (!m_mappings.m_map_from_k_6b.exists(a_code_symbol_6b)) begin
            //type of error is symbol error
            out_s.decode_err = 2;//symbol error
         //no more decoding since 6b code word is corrupt
         end else begin
            control_symb_6b = endec_8b10b_k_6b_e'(a_code_symbol_6b);

            `uvm_info("DECODER_8b10b",$sformatf("Decoded 5b6b control symbol is %s ", control_symb_6b.name()), UVM_HIGH)

            map_out = m_mappings.m_map_from_k_6b[control_symb_6b];
            //get 5b6b  coded control word disparity based on the representation(0->-2, 1->0, 2->2)
            code_word_disp = (map_out[6:5] == 0) ? -2 : ((map_out[6:5] == 1) ? 0 : 2);
            out_s.decode_5b6b_val = map_out[4:0];

            if (code_word_disp != m_running_disp) begin
               //calculate new disparity
               m_running_disp += code_word_disp;
            end else begin//means disparity error
               //type of error is symbol error
               out_s.decode_err = 1;//disparity error
            end
         end
      end

      return out_s;
   endfunction


   /* Function to decode the 3b4b coded symbol
    * @param a_code_symbol_4b - the 3b4b encoded code word
    * @return struct containing the decoded bits and the error status
    */
   virtual function endec_8b10b_3b4b_decode_s decode_3b4b_c_symbol (input bit [3:0] a_code_symbol_4b);
      bit[5:0] map_out;
      int code_word_disp;

      endec_8b10b_3b4b_decode_s out_s;

      if ((m_running_disp !=-1) && (m_running_disp != 1)) begin
         out_s.decode_err = 1;//disparity error
      end
      else begin

         if (m_running_disp == -1) begin
            endec_8b10b_k_4b_n_e c_symbol_4b_n;

            if (!m_mappings.m_map_from_k_4b_n.exists(a_code_symbol_4b)) begin
               //type of error is symbol error
               out_s.decode_err = 2;//symbol error
            //no more decoding since 6b code word is corrupt
            end else begin
               c_symbol_4b_n = endec_8b10b_k_4b_n_e'(a_code_symbol_4b);

               `uvm_info("DECODER_8b10b",$sformatf("Decoded 3b4b control symbol is %s ", c_symbol_4b_n.name()), UVM_HIGH)

               map_out = m_mappings.m_map_from_k_4b_n[c_symbol_4b_n];
               out_s.decode_3b4b_val = map_out[2:0];

               //get 3b4b  coded control word disparity based on the representation(0->-2, 1->0, 2->2)
               code_word_disp = (map_out[5:4] == 0) ? -2 : ((map_out[5:4] == 1) ? 0 : 2);
               if (c_symbol_4b_n == 4'b1100) begin
                  m_running_disp = -1;
               end
               else begin
                  if (code_word_disp != m_running_disp) begin
                     //calculate new disparity
                     m_running_disp += code_word_disp;
                  end else begin//means disparity error
                     //type of error is symbol error
                     out_s.decode_err = 2;//disparity error
                  end
               end
            end
         end else begin
            endec_8b10b_k_4b_p_e c_symbol_4b_p;

            if (!m_mappings.m_map_from_k_4b_p.exists(a_code_symbol_4b)) begin
               //type of error is symbol error
               out_s.decode_err = 2;//symbol error
            //no more decoding since 6b code word is corrupt
            end else begin
               c_symbol_4b_p = endec_8b10b_k_4b_p_e'(a_code_symbol_4b);

               `uvm_info("DECODER_8b10b",$sformatf("Decoded 3b4b control symbol is %s ", c_symbol_4b_p.name()), UVM_HIGH)

               map_out = m_mappings.m_map_from_k_4b_p[c_symbol_4b_p];
               out_s.decode_3b4b_val = map_out[2:0];

               //get 3b4b  coded control word disparity based on the representation(0->-2, 1->0, 2->2)
               code_word_disp = (map_out[5:4] == 0) ? -2 : ((map_out[5:4] == 1) ? 0 : 2);
               if (c_symbol_4b_p == 6'b0011) begin
                  m_running_disp = 1;
               end
               else begin
                  if (code_word_disp != m_running_disp) begin
                     //calculate new disparity
                     m_running_disp += code_word_disp;
                  end else begin//means disparity error
                     //type of error is symbol error
                     out_s.decode_err = 1;//disparity error
                  end
               end
            end
         end
      end

      return out_s;
   endfunction


endclass

`endif//ENDEC_8b10b_DECODER_SVH
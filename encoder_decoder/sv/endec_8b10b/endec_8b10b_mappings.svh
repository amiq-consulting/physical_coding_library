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
 * MODULE:      endec_8b10b_mappings.sv
 * PROJECT:     endec_8b10b
 *
 *
 * Description: File containing the class implementing the mappings between
 *              uncoded symbols and disparity and their coded equivalents 
 *****************************************************************************/


`ifndef ENDEC_8b10b_MAPPINGS_SVH
`define ENDEC_8b10b_MAPPINGS_SVH

/* Decoder driver
 */
class endec_8b10b_mappings extends uvm_object;
   `uvm_object_utils(endec_8b10b_mappings)

   //
   // maps 5b6b symbols to the corresponding uncoded data bits and disparity of the symbol
   // the 2 MSBs hold the disparity and the 5 LSBs hold the uncoded bits
   // disparity(of coded word) is represented like this: -2->0, 0->1, 2->2
   bit[6:0] m_map_from_5b6b [endec_8b10b_d_6b_e];
   // maps uncoded data bits and disparity of the symbol to the corresponding 5b6b symbol
   // the 2 MSBs hold the running disparity and the 5 LSBs hold the uncoded bits
   // running disparity is represented like this: -1->0, 1->1
   endec_8b10b_d_6b_e m_map_to_5b6b [bit[6:0]];

   /* Function that builds a mapping between a 5b6b encoded word and
    * it's un-coded counterpart together with it's disparity
    */
   virtual function void build_from_5b6b_map ();
      endec_8b10b_d_6b_e code_word_6b = code_word_6b.first();
      bit[6:0] map_entry;
      int symb_vector_5b6b = `ENDEC_5B6B_SYMBOL_HAS_DOUBLE_ENCODING;
      //disparity possible values are: -2, 0, 2
      for (int iter = 0; iter < 32; iter++) begin
         if (symb_vector_5b6b[iter] == 1) begin
            //for disparity '2' use value '2'
            map_entry =  (2<<5) + iter;
            m_map_from_5b6b[code_word_6b] = map_entry;
            code_word_6b = code_word_6b.next();
            //for '-2' disparity use value '0'
            map_entry = iter;
            m_map_from_5b6b[code_word_6b] = map_entry;
         end else begin
            //for disparity '0' use value '1'
            map_entry = (1<<5) + iter;
            m_map_from_5b6b[code_word_6b] = map_entry;
         end
         code_word_6b = code_word_6b.next();
      end
   endfunction

   /* Function that builds the  mapping in the direction opposite to
    * the one above
    */
   virtual function void build_to_5b6b_map ();
      //map all 32 values for each disparity
      endec_8b10b_d_6b_e code_word_6b = code_word_6b.first();
      bit[6:0] map_key;
      int symb_vector_5b6b = `ENDEC_5B6B_SYMBOL_HAS_DOUBLE_ENCODING;

      for (int iter = 0; iter <= 31; iter++) begin
         //add for negative disparity, use value '0' for running disparity '-1'
         map_key = iter;
         m_map_to_5b6b[map_key] = code_word_6b;
         //add for positive disparity, use value '1' for running disparity '-1'
         if (symb_vector_5b6b[iter] == 1) begin
            code_word_6b = code_word_6b.next();
         end
         map_key = (1<<5) + iter;
         m_map_to_5b6b[map_key] = code_word_6b;
         code_word_6b = code_word_6b.next();
      end
   endfunction

   // maps 3b4b symbols to the corresponding uncoded data bits and disparity of the symbol
   // the 2 MSBs hold the disparity and the 4 LSBs hold the uncoded bits
   // disparity(of coded word) is represented like this: -2->0, 0->1, 2->2
   bit[5:0] m_map_from_3b4b [endec_8b10b_d_4b_e];
   // maps uncoded data bits and disparity of the symbol to the corresponding 3b4b symbol
   // the 2 MSBs hold the running disparity and the 4 LSBs hold the uncoded bits
   // running disparity is represented like this: -1->0, 1->1
   endec_8b10b_d_4b_e m_map_to_3b4b [bit[5:0]];

   /* Function that builds a mapping between a 3b4b encoded word and
    * it's un-coded counterpart together with it's disparity
    * use extra data value '8' for alternative coding of data value '7'
    */
   virtual function void build_from_3b4b_map ();
      endec_8b10b_d_4b_e code_word_4b = code_word_4b.first();
      bit[5:0] map_entry;
      int symb_vector_3b4b = `ENDEC_3B4B_SYMBOL_HAS_DOUBLE_ENCODING;

      for (int iter = 0; iter <= 8; iter++) begin
         if (symb_vector_3b4b[iter] == 1) begin
            map_entry = (2<<4) + iter;//symbol disparity is 2
            m_map_from_3b4b[code_word_4b] = map_entry;
            code_word_4b = code_word_4b.next();
            map_entry = iter;//symbol disparity is -2, use value '0' to represent
            m_map_from_3b4b[code_word_4b] = map_entry;
         end else begin
            map_entry = (1<<4) + iter;//symbol disparity is 0
            m_map_from_3b4b[code_word_4b] = map_entry;
         end
         code_word_4b = code_word_4b.next();
      end
   endfunction

   /* Function that builds the  mapping in the direction opposite to
    * the one above
    */
   virtual function void build_to_3b4b_map ();
      endec_8b10b_d_4b_e code_word_4b = code_word_4b.first();
      bit[5:0] map_key;
      int symb_vector_3b4b = `ENDEC_3B4B_SYMBOL_HAS_DOUBLE_ENCODING;

      for (int iter = 0; iter <= 8; iter++) begin
         //add for negative disparity(use value '0' for the array entry)
         map_key = iter;
         m_map_to_3b4b[map_key] = code_word_4b;
         //add for positive disparity(use value '1' for the array entry)
         if (symb_vector_3b4b[iter] == 1) begin
            code_word_4b = code_word_4b.next();
         end
         map_key = (1<<4) + iter;
         m_map_to_3b4b[map_key] = code_word_4b;
         code_word_4b = code_word_4b.next();
      end
   endfunction

   // maps 5b6b coded word of the control symbols to the corresponding uncoded data bits and disparity value of the
   // symbol the 2 MSBs hold the disparity value of the coded symbol and the 5 LSBs hold the uncoded bits
   // disparity(of coded word) is represented like this: -2->0, 0->1, 2->2
   bit[6:0] m_map_from_k_6b[endec_8b10b_k_6b_e];
   // maps uncoded data bits and disparity of the coded control symbol to the corresponding 5b6b symbol
   // the 2 MSBs hold the running disparity and the 5 LSBs hold the uncoded bits
   // running disparity is represented like this: -1->0, 1->1
   endec_8b10b_k_6b_e m_map_to_k_6b[bit[6:0]];

   /* Function that builds a mapping between a 5b6b encoded word,
    * part of the control symbols, and it's un-coded counterpart
    * together with it's disparity
    */
   virtual function void build_from_k_6b_map ();
      endec_8b10b_k_6b_e k_word_6b = k_word_6b.first();
      bit[6:0] map_entry;
      //values that are encoded
      bit [4:0] coded_values [5] = '{28, 23, 27, 29, 30};

      for (int iter = 0;iter < k_word_6b.num(); iter++) begin
         int sel_coded_val = iter/2;
         //disparity representation 2->2, -2->0
         bit[1:0] disparity = ((iter%2) == 0) ? 2 : 0;
         map_entry =  (disparity<<5) + coded_values[sel_coded_val];
         m_map_from_k_6b[k_word_6b] = map_entry;
         k_word_6b = k_word_6b.next();
      end
   endfunction

   /* Function that builds the  mapping in the direction opposite to
    * the one above
    */
   virtual function void build_to_k_6b_map ();
      endec_8b10b_k_6b_e k_word_6b = k_word_6b.first();
      bit[6:0] map_key;
      //values that are encoded
      bit [4:0] coded_values [5] = '{28, 23, 27, 29, 30};

      for (int iter = 0;iter < k_word_6b.num(); iter++) begin
         int sel_coded_val = iter/2;
         //running disparity representation -1->0, 1->1
         bit disparity = ((iter%2) == 0) ? 0 : 1;
         map_key = (disparity<<5) + coded_values[sel_coded_val];
         m_map_to_k_6b[map_key] = k_word_6b;
         k_word_6b = k_word_6b.next();
      end
   endfunction

   // maps 3b4b coded word(for negative running disparity) of the control symbols to the corresponding uncoded data
   // bits and disparity value  of the symbol the 2 MSBs hold the disparity value of the coded symbol and the 5 LSBs
   // hold the uncoded bits disparity(of coded word) is represented like this: -2->0, 0->1, 2->2
   bit[5:0] m_map_from_k_4b_n[endec_8b10b_k_4b_n_e];
   // maps uncoded data bits and disparity of the coded control symbol to the corresponding 5b6b symbol
   // the 2 MSBs hold the running disparity and the 5 LSBs hold the uncoded bits
   // running disparity is represented like this: -1->0, 1->1
   endec_8b10b_k_4b_n_e m_map_to_k_4b_n[bit[5:0]];

   /* Function that builds a mapping between a 5b6b encoded word, part
    * of the control symbols, and it's un-coded counterpart together with
    * it's disparity
    */
   virtual function void build_from_k_4b_n_map ();
      endec_8b10b_k_4b_n_e k_word_4b = k_word_4b.first();
      bit[5:0] map_entry;

      for (int iter = 0;iter < k_word_4b.num(); iter++) begin
         // disparity is '2' in the cases below
         if (iter inside {0, 4, 7}) begin
            map_entry = (2<<4) + iter;
         end
         else begin
            map_entry = (1<<4) + iter;//symbol disparity is 0
         end
         m_map_from_k_4b_n[k_word_4b] = map_entry;

         k_word_4b = k_word_4b.next();
      end
   endfunction

   /* Function that builds the  mapping in the direction opposite to
    * the one above
    */
   virtual function void build_to_k_4b_n_map ();
      endec_8b10b_k_4b_n_e k_word_4b = k_word_4b.first();
      bit[5:0] map_key;

      for (int iter = 0; iter <= 7; iter++) begin
         //add for negative disparity(use value '0' for the array entry)
         //for this map we always have negative running disparity
         map_key = iter;
         m_map_to_k_4b_n[map_key] = k_word_4b;
         k_word_4b = k_word_4b.next();
      end
   endfunction

   // maps 3b4b coded word(for positive running disparity) of the control symbols to the corresponding uncoded data
   // bits and disparity value  of the symbol the 2 MSBs hold the disparity value of the coded symbol and the 5 LSBs
   // hold the uncoded bits disparity(of coded word) is represented like this: -2->0, 0->1, 2->2
   bit[5:0] m_map_from_k_4b_p[endec_8b10b_k_4b_p_e];
   // maps uncoded data bits and disparity of the coded control symbol to the corresponding 5b6b symbol
   // the 2 MSBs hold the running disparity and the 5 LSBs hold the uncoded bits
   // running disparity is represented like this: -1->0, 1->1
   endec_8b10b_k_4b_p_e m_map_to_k_4b_p[bit[5:0]];

   /* Function that builds a mapping between a 3b4b encoded word,part of
    * the control symbols, and it's un-coded counterpart together with
    * it's disparity
    */
   virtual function void build_from_k_4b_p_map ();
      endec_8b10b_k_4b_p_e k_word_4b = k_word_4b.first();
      bit[5:0] map_entry;

      for (int iter = 0;iter < k_word_4b.num(); iter++) begin
         // disparity is '-2' in the cases below
         if (iter inside {0, 4, 7}) begin
            map_entry = iter;
         end
         else begin
            map_entry = (1<<4) + iter;//symbol disparity is 0
         end
         m_map_from_k_4b_p[k_word_4b] = map_entry;

         k_word_4b = k_word_4b.next();
      end
   endfunction

   /* Function that builds the  mapping in the direction opposite to
    * the one above
    */
   virtual function void build_to_k_4b_p_map ();
      endec_8b10b_k_4b_p_e k_word_4b = k_word_4b.first();
      bit[5:0] map_key;

      for (int iter = 0; iter <= 7; iter++) begin
         //add for positive disparity(use value '1' for the array entry)
         //for this map we always have positive running disparity
         map_key = (1<<4) + iter;
         m_map_to_k_4b_p[map_key] = k_word_4b;
         k_word_4b = k_word_4b.next();
      end
   endfunction
   
   
   /*constructor
    * @param name - name of the component instance
    */
   function new (input string name = "endec_8b10b_mappings");
      super.new(name);
      //build maps for 5b6b data symbols
      build_from_5b6b_map();
      build_to_5b6b_map();
      //build maps for 3b4b data symbols
      build_from_3b4b_map();
      build_to_3b4b_map();
      //build maps for 6b control symbols
      build_from_k_6b_map();
      build_to_k_6b_map();
      //build maps for 4b control symbols
      build_from_k_4b_n_map();
      build_to_k_4b_n_map();
      build_from_k_4b_p_map();
      build_to_k_4b_p_map();
   endfunction
      
endclass

`endif//ENDEC_8b10b_MAPPINGS_SVH
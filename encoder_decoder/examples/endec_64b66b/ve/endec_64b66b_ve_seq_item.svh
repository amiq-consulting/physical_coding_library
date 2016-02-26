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
 * MODULE:      endec_64b66b_ve_seq_item.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the implementation file of endec_64b66b sequence item
 *******************************************************************************/


`ifndef ENDEC_64b66b_VE_SEQ_ITEM_SVH
`define ENDEC_64b66b_VE_SEQ_ITEM_SVH


/* Class modeling the data used in the
 * 64/66 coding
 */
class endec_64b66b_ve_seq_item extends uvm_sequence_item;
   `uvm_object_utils(endec_64b66b_ve_seq_item)


   // XGMII interface type input
   // 4 bit indicating type of the 4 bytes inside data0
   rand bit [3:0]  m_control0;
   // first 32 bits of data transmitted
   rand bit [31:0] m_data0;
   // 4 bit indicating type of the 4 bytes inside data0
   rand bit [3:0]  m_control1;
   // second 32 bits of data transmitted
   rand bit [31:0] m_data1;


   // to be updated after coding process
   endec_64b66b_rx_tx_block_type_e m_tx_block_type;

   // 64/66 coded data
   bit[65:0] m_code_block_66b;

   // scrambled 64 code block data, 2bit header is excluded
   bit [63:0] m_scrmbl_code_blk;

   // de-scrambled 64 code block data, 2bit header is excluded
   bit [63:0] m_descrmbl_code_blk;

   // output of the decode process
   bit [71:0] m_decoded_xgmii_data;


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_seq_item_inst");
      super.new(name);
   endfunction


   /* Function returning a string with the name of the sequence item
    * @return a string with a unique name for each item type
    */
   virtual function string  my_type();
      return "endec_64b66b_seq_item_basic";
   endfunction

   /* Function that outputs information related to this item
    * @return a string with details of the item contents
    */
   virtual function string convert2string();
      string result = "\n";

      result = {result,$sformatf("Item type is %s\n", my_type())};
      result = {result,$sformatf("Control0 value is %x\n", m_control0)};
      result = {result,$sformatf("Data0 value is %x\n", m_data0)};
      result = {result,$sformatf("Control1 value is %x\n", m_control1)};
      result = {result,$sformatf("Data1 value is %x\n", m_data1)};

      return result;
   endfunction

endclass


/* Implements C type block as defined in the standard
 * The vector contains one of the following:
 * a) eight valid control characters other than /O/, /S/, /T/ and /E/;
 * b) one valid ordered_set and four valid control characters other than /O/, /S/ and /T/;
 * c) two valid ordered sets
 * This class generates only IDLE control codes
 */
class endec_64b66b_ve_c_blk_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_c_blk_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   // constraint for c_block
   constraint c_block_const_control {
      m_tx_c_both inside {8'hff, 8'h8f, 8'hf8, 8'h88};
   };

   //constraint for s_block
   constraint s_block_const_data {
      (m_tx_c_both == 8'hff) -> foreach (m_bytes_to_xgmii_ctrl[iter]) m_bytes_to_xgmii_ctrl[iter] == I_CONTROL;

         (m_tx_c_both == 8'hf8) -> {
         (m_bytes_to_xgmii_ctrl[3] == Q_CONTROL) && (m_bytes_to_xgmii_ctrl[7] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[6] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[5] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[4] == I_CONTROL)
      };

      (m_tx_c_both == 8'h8f) -> {
         (m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
      };

      (m_tx_c_both == 8'h88) -> {
         (m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == Q_CONTROL)
      };

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   // constraint for XGMII input
   constraint xgmii_input_const {
      m_control0 == m_tx_c_both[7:4];
      m_data0 == {m_bytes_to_xgmii_ctrl[7], m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5], m_bytes_to_xgmii_ctrl[4]};
      m_control1 == m_tx_c_both[3:0];
      m_data1 == {m_bytes_to_xgmii_ctrl[3], m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1], m_bytes_to_xgmii_ctrl[0]};

      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;
   }


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_c_block_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string witht the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_c_block_seq_item";
   endfunction


endclass


/* Implements C type block as defined in the standard
 * The vector contains one of the following:
 * a) eight valid control characters other than /O/, /S/, /T/ and /E/;
 * b) one valid ordered_set and four valid control characters other than /O/, /S/ and /T/;
 * c) two valid ordered sets
 * This class generates both IDLE and ERROR control codes
 */
class endec_64b66b_ve_c_blk_idle_and_err_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_c_blk_idle_and_err_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   //constraint for c_block
   constraint c_block_const_control {
      m_tx_c_both inside {8'hff, 8'h8f, 8'hf8, 8'h88};
   };

   //constraint for s_block data
   constraint s_block_const_data {
      (m_tx_c_both == 8'hff) -> foreach (m_bytes_to_xgmii_ctrl[iter]) m_bytes_to_xgmii_ctrl[iter] == I_CONTROL;// only IDLE allowed for this case

         (m_tx_c_both == 8'hf8) -> {
         (m_bytes_to_xgmii_ctrl[3] == Q_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[7] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[6] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[5] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[4] inside {I_CONTROL,E_CONTROL })
      };

      (m_tx_c_both == 8'h8f) -> {
         (m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[3] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL,E_CONTROL })
      };

      (m_tx_c_both == 8'h88) -> {
         (m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[3] == Q_CONTROL)
      };

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   // constraint for XGMII input
   constraint xgmii_input_const {
      m_control0 == m_tx_c_both[7:4];
      m_data0 == {
         m_bytes_to_xgmii_ctrl[7], m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5], m_bytes_to_xgmii_ctrl[4]
      };
      m_control1 == m_tx_c_both[3:0];
      m_data1 == {
         m_bytes_to_xgmii_ctrl[3], m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1], m_bytes_to_xgmii_ctrl[0]
      };

      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;
   }


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_c_block_idle_and_error_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_c_block_idle_and_error_seq_item";
   endfunction

endclass


/* Implements S type block as defined in the standard
 * S type definition : The vector contains an /S/ in its first or fifth character, any characters before the S
 * character are valid control characters other than /O/, /S/ and /T/ or form a valid
 * ordered_set, and all characters following the /S/ are data characters.
 * This class generates only IDLE control codes
 */
class endec_64b66b_ve_s_blk_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_s_blk_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   //constraint for s_block control
   constraint s_block_const_control {
      m_tx_c_both inside {8'h80, 8'hf8, 8'h88};
   };

   // constraint for s_block data
   constraint s_block_const_data {
      (m_tx_c_both == 8'h80) -> {
         m_bytes_to_xgmii_ctrl[7] == S_CONTROL
      };

      (m_tx_c_both == 8'hf8) -> {
         (m_bytes_to_xgmii_ctrl[7] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[6] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[5] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[4] == I_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[3] == S_CONTROL)
      };


      (m_tx_c_both == 8'h88) -> ((m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == S_CONTROL));

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   //constraint for XGMII input
   constraint xgmii_input_const {
      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      m_control0 == m_tx_c_both[7:4];
      m_control1 == m_tx_c_both[3:0];

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;

      m_data0 == {
         m_bytes_to_xgmii_ctrl[7], m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5], m_bytes_to_xgmii_ctrl[4]
      };
      m_data1 == {
         m_bytes_to_xgmii_ctrl[3], m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1], m_bytes_to_xgmii_ctrl[0]
      };
   }


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_s_block_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_s_block_seq_item";
   endfunction

endclass


/* Implements S type block as defined in the standard
 * S type definition : The vector contains an /S/ in its first or fifth character, any characters before the S
 * character are valid control characters other than /O/, /S/ and /T/ or form a valid
 * ordered_set, and all characters following the /S/ are data characters.
 * This class generates both IDLE and ERROR control codes
 */
class endec_64b66b_ve_s_blk_idle_and_err_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_s_blk_idle_and_err_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   // constraint for s_block control
   constraint s_block_const_control {
      m_tx_c_both inside {8'h80, 8'hf8, 8'h88};
   };

   //constraint for s_block data
   constraint s_block_const_data {
      (m_tx_c_both == 8'h80) -> {m_bytes_to_xgmii_ctrl[7] == S_CONTROL};


      (m_tx_c_both == 8'hf8) -> {
         (m_bytes_to_xgmii_ctrl[7] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[6] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[5] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[4] inside {I_CONTROL,E_CONTROL }) &&
         (m_bytes_to_xgmii_ctrl[3] == S_CONTROL)
      };

      (m_tx_c_both == 8'h88) -> {
         (m_bytes_to_xgmii_ctrl[7] == Q_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == S_CONTROL)
      };

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   // constraint for XGMII input
   constraint xgmii_input_const {
      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      m_control0 == m_tx_c_both[7:4];
      m_control1 == m_tx_c_both[3:0];

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;

      m_data0 == {m_bytes_to_xgmii_ctrl[7], m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5], m_bytes_to_xgmii_ctrl[4]};
      m_data1 == {m_bytes_to_xgmii_ctrl[3], m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1], m_bytes_to_xgmii_ctrl[0]};
   }


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_s_block_idle_and_error_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_s_block_idle_and_error_seq_item";
   endfunction

endclass


/* Implements T type block as defined in the standard
 * T type definition : vector contains a /T/ in one of its characters, all characters before the /R/
 * are data characters and all characters following the /T/ are valid control characters other
 * than /O/, /S/ and /T/.
 * This class generates only IDLE control codes
 */
class endec_64b66b_ve_t_blk_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_t_blk_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   //constraint for t_block control
   constraint t_block_const_control {
      m_tx_c_both inside { 8'hff, 8'h7f, 8'h3f, 8'h1f, 8'h0f, 8'h07, 8'h03, 8'h01};
   };

   //constraint for t_block data
   constraint t_block_const_data {
      (m_tx_c_both == 8'hff) -> {
         (m_bytes_to_xgmii_ctrl[7] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[6] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[5] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[4] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h7f) -> {
         (m_bytes_to_xgmii_ctrl[6] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[5] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[4] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h3f) -> {
         (m_bytes_to_xgmii_ctrl[5] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[4] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[3] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) && (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h1f) -> {
         (m_bytes_to_xgmii_ctrl[4] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[3] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h0f) -> {
         (m_bytes_to_xgmii_ctrl[3] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[2] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h07) -> {
         (m_bytes_to_xgmii_ctrl[2] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[1] == I_CONTROL) &&
            (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
         )
      };

      (m_tx_c_both == 8'h03) -> {
         (m_bytes_to_xgmii_ctrl[1] == T_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[0] == I_CONTROL)
      };

      (m_tx_c_both == 8'h01) -> {
         (m_bytes_to_xgmii_ctrl[0] == T_CONTROL)
      };

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   //constraint for XGMII input
   constraint xgmii_input_const {
      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      m_control0 == m_tx_c_both[7:4];
      m_control1 == m_tx_c_both[3:0];

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;

      m_data0 == {
         m_bytes_to_xgmii_ctrl[7],m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5],m_bytes_to_xgmii_ctrl[4]
      };
      m_data1 == {
         m_bytes_to_xgmii_ctrl[3],m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1],m_bytes_to_xgmii_ctrl[0]
      };
   }


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_t_block_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_t_block_seq_item";
   endfunction

endclass


/* Implements T type block as defined in the standard
 * T type definition : vector contains a /T/ in one of its characters, all characters before the /R/
 * are data characters and all characters following the /T/ are valid control characters other
 * than /O/, /S/ and /T/.
 * This class generates both IDLE and ERROR control codes
 */
class endec_64b66b_ve_t_blk_idle_and_err_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_t_blk_idle_and_err_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   //constraint for t_block control
   constraint t_block_const_control {
      m_tx_c_both inside { 8'hff, 8'h7f, 8'h3f, 8'h1f, 8'h0f, 8'h07, 8'h03, 8'h01};
   };

   //constraint for t_block data
   constraint t_block_const_data {
      (m_tx_c_both == 8'hff) -> {
         (m_bytes_to_xgmii_ctrl[7] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[6] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[5] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[4] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[3] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h7f) -> {
         (m_bytes_to_xgmii_ctrl[6] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[5] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[4] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[3] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h3f) -> {
         (m_bytes_to_xgmii_ctrl[5] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[4] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[3] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h1f) -> {
         (m_bytes_to_xgmii_ctrl[4] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[3] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h0f) -> {
         (m_bytes_to_xgmii_ctrl[3] == T_CONTROL)
         &&
         (
            (m_bytes_to_xgmii_ctrl[2] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h07) -> {
         (m_bytes_to_xgmii_ctrl[2] == T_CONTROL) &&
         (
            (m_bytes_to_xgmii_ctrl[1] inside {I_CONTROL, E_CONTROL}) &&
            (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
         )
      };

      (m_tx_c_both == 8'h03) -> {
         (m_bytes_to_xgmii_ctrl[1] == T_CONTROL) &&
         (m_bytes_to_xgmii_ctrl[0] inside {I_CONTROL, E_CONTROL})
      };

      (m_tx_c_both == 8'h01) -> {
         (m_bytes_to_xgmii_ctrl[0] == T_CONTROL)
      };

      solve m_tx_c_both before m_bytes_to_xgmii_ctrl;
   };

   //constraint for XGMII input
   constraint xgmii_input_const {
      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      m_control0 == m_tx_c_both[7:4];
      m_control1 == m_tx_c_both[3:0];

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;

      m_data0 == {
         m_bytes_to_xgmii_ctrl[7],m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5],m_bytes_to_xgmii_ctrl[4]
      };
      m_data1 == {
         m_bytes_to_xgmii_ctrl[3],m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1],m_bytes_to_xgmii_ctrl[0]
      };
   };


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_t_block_idle_and_error_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_t_block_idle_and_error_seq_item";
   endfunction

endclass


/* Implements D type block as defined in the standard
 * D type definition : The vector contains eight data characters
 */
class endec_64b66b_ve_d_block_seq_item extends endec_64b66b_ve_seq_item;
   `uvm_object_utils(endec_64b66b_ve_d_block_seq_item)


   // variable to convert XGMII control to bytes
   rand byte unsigned m_bytes_to_xgmii_ctrl [8];
   // holds both control indicators inputs
   rand byte unsigned m_tx_c_both;

   //constraint for d_block control
   constraint d_blk_const_ctrl {
      m_tx_c_both == 0;
   };

   //constraint for XGMII input
   constraint xgmii_input_const {
      solve m_tx_c_both before m_control0;
      solve m_tx_c_both before m_control1;

      m_control0 == m_tx_c_both[7:4];
      m_control1 == m_tx_c_both[3:0];

      solve m_bytes_to_xgmii_ctrl before m_data0;
      solve m_bytes_to_xgmii_ctrl before m_data1;

      m_data0 == {
         m_bytes_to_xgmii_ctrl[7],m_bytes_to_xgmii_ctrl[6],
         m_bytes_to_xgmii_ctrl[5],m_bytes_to_xgmii_ctrl[4]
      };
      m_data1 == {
         m_bytes_to_xgmii_ctrl[3],m_bytes_to_xgmii_ctrl[2],
         m_bytes_to_xgmii_ctrl[1],m_bytes_to_xgmii_ctrl[0]
      };
   };


   /* Constructor
    * @param name : name for this component instance
    */
   function new (string name = "endec_64b66b_d_block_seq_item_inst");
      super.new(name);
   endfunction


   /* Function override delivering the type of the item
    * @return the string with the name of this item
    */
   virtual function string  my_type();
      return "endec_64b66b_d_block_seq_item";
   endfunction

endclass

`endif//ENDEC_64b66b_VE_SEQ_ITEM_SVH
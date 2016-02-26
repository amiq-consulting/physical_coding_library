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
 * MODULE:      endec_64b66b_ve_sequence_lib.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This file contains the sequence library.
 *******************************************************************************/
`ifndef ENDEC_64b66b_VE_SEQUENCE_LIB_SVH
`define ENDEC_64b66b_VE_SEQUENCE_LIB_SVH



/* Basic sequence with random items
 */
class endec_64b66b_ve_seq extends uvm_sequence #(endec_64b66b_ve_seq_item);
   `uvm_object_utils(endec_64b66b_ve_seq)

   // sequence item numbers
   rand int m_num_of_items;
   //64b66b sequence item
   endec_64b66b_ve_seq_item m_seq_item;


   /* Default constructor
    * @param name : instance name
    */
   function new(string name = "");
      super.new(name);
   endfunction


   /* Sequence body task implementation
    */
   virtual task body();
      int unsigned index;

      repeat(m_num_of_items) begin
         bit [1:0] dice_on_item;
         void'(std::randomize(dice_on_item));


         case (dice_on_item)
            0: m_seq_item = endec_64b66b_ve_s_blk_idle_and_err_seq_item::type_id::create("s_seq_item");
            1: m_seq_item = endec_64b66b_ve_d_block_seq_item::type_id::create("d_seq_item");
            2: m_seq_item = endec_64b66b_ve_t_blk_idle_and_err_seq_item::type_id::create("t_seq_item");
            3: m_seq_item = endec_64b66b_ve_c_blk_idle_and_err_seq_item::type_id::create("c_seq_item");
         //4,5,6,7 : seq_item = endec_64b66b_seq_item::type_id::create("seq_item");
         endcase


         start_item(m_seq_item);         
         if (!m_seq_item.randomize())begin
            `uvm_fatal("ENDEC_64b66b_SEQ_LIB", "Randomization failed.")
         end
         finish_item(m_seq_item);

         index += 1;
      end
   endtask

endclass


/* Sequence generating legal input
 *
 */
class endec_64b66b_ve_all_legal_seq extends uvm_sequence#(endec_64b66b_ve_seq_item);
   `uvm_object_utils(endec_64b66b_ve_all_legal_seq)

   //sequence items number
   rand int m_num_of_items;
   //64b66b sequence item
   endec_64b66b_ve_seq_item m_seq_item;


   /* Default constructor
    * @param name : instance name
    */
   function new(string name = "");
      super.new(name);
   endfunction


   /* Sequence body task implementation
    */
   virtual task body();
      string prev_seq_type = "";


      repeat(m_num_of_items) begin
         // initial item
         if (prev_seq_type == "") begin
            m_seq_item = endec_64b66b_ve_c_blk_idle_and_err_seq_item::type_id::create("c_seq_item");
            prev_seq_type = m_seq_item.my_type();
         end
         else if(
               prev_seq_type inside {"endec_64b66b_c_block_seq_item", "endec_64b66b_c_block_idle_and_error_seq_item"}
            )begin
            // generate only C type or S type
            bit dice_on_seq;
            void'(std::randomize(dice_on_seq));

            if (dice_on_seq == 1) begin
               m_seq_item = endec_64b66b_ve_s_blk_idle_and_err_seq_item::type_id::create("s_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
            else begin
               m_seq_item = endec_64b66b_ve_c_blk_idle_and_err_seq_item::type_id::create("c_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end

            prev_seq_type = m_seq_item.my_type();
         end
         else if(
               prev_seq_type inside {"endec_64b66b_s_block_seq_item", "endec_64b66b_s_block_idle_and_error_seq_item"}
            )begin
            // generate only D type or T type
            bit dice_on_seq;
            void'(std::randomize(dice_on_seq));

            if (dice_on_seq == 1) begin
               m_seq_item = endec_64b66b_ve_t_blk_idle_and_err_seq_item::type_id::create("t_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
            else begin
               m_seq_item = endec_64b66b_ve_d_block_seq_item::type_id::create("d_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end

         end
         else if(
               prev_seq_type inside {"endec_64b66b_t_block_seq_item", "endec_64b66b_t_block_idle_and_error_seq_item"}
            )begin
            // generate only C type or S type
            bit dice_on_seq;
            void'(std::randomize(dice_on_seq));

            if (dice_on_seq == 1) begin
               m_seq_item = endec_64b66b_ve_s_blk_idle_and_err_seq_item::type_id::create("s_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
            else begin
               m_seq_item = endec_64b66b_ve_c_blk_idle_and_err_seq_item::type_id::create("c_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
         end
         else if (prev_seq_type == "endec_64b66b_d_block_seq_item") begin
            // generate only D type or T type
            bit dice_on_seq;
            void'(std::randomize(dice_on_seq));

            if (dice_on_seq == 1) begin
               m_seq_item = endec_64b66b_ve_d_block_seq_item::type_id::create("d_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
            else begin
               m_seq_item = endec_64b66b_ve_t_blk_idle_and_err_seq_item::type_id::create("t_seq_item");
               prev_seq_type = m_seq_item.my_type();
            end
         end


         start_item(m_seq_item);
         if (!m_seq_item.randomize())begin
            `uvm_fatal("ENDEC_64b66b_SEQ_LIB", "Randomization failed.")
         end
         finish_item(m_seq_item);
      end

   endtask

endclass

`endif//ENDEC_64b66b_VE_SEQUENCE_LIB_SVH
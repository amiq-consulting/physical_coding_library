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
 * MODULE:      endec_64b66b_driver_with_scrambler.svh
 * PROJECT:     physical_coding_algorithms
 *
 *
 * Description: This file contains a specialization of the endec_64b66b driver
 *              that instantiates a multiplicative type scrambler and descrambler
 *******************************************************************************/


`ifndef ENDEC_64b66b_DRIVER_WITH_SCRAMBLER_SVH
`define ENDEC_64b66b_DRIVER_WITH_SCRAMBLER_SVH


/* Driver class specialization instantiating a scrambler and a descrambler
 *
 */
class endec_64b66b_driver_with_scrambler extends endec_64b66b_ve_drv;
   `uvm_component_utils(endec_64b66b_driver_with_scrambler)


   //parameters for the scrambler and descrambler
   parameter ORDER = 64;
   parameter TAPS = 'h9010030500008000;


   // multiplicative scrambler instance
   scrambler_multiplicative   #(ORDER, TAPS) m_mult_scrambler;
   // multiplicative descrambler instance
   descrambler_multiplicative #(ORDER, TAPS) m_mult_descrambler;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(string name, uvm_component parent);
      super.new(name, parent);

      // allocate the multiplicative scrambler and descrambler
      m_mult_scrambler   =   scrambler_multiplicative #(ORDER,TAPS)::type_id::create(
         "m_mult_scrambler",
         this
      );
      m_mult_descrambler = descrambler_multiplicative #(ORDER,TAPS)::type_id::create(
         "m_mult_descrambler",
         this
      );
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
   endfunction


   /* UVM connect_phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
   endfunction


   /* UVM run_phase
    * @param phase - current phase
    */
   virtual task run_phase(uvm_phase phase);
      endec_64b66b_ve_seq_item encoder_item;


      // bit-stream input for scrambler
      bs_t scrmbl_input;
      // bit-stream output for scrambler
      bs_t scrmbl_output;
      // bit-stream output of descrambler
      bs_t descrmbl_output;


      forever begin
         // get item from the sequencer
         seq_item_port.get_next_item(encoder_item);

         // print item
         `uvm_info("DRIVER_64b66b_WITH_SCRAMBLER", encoder_item.convert2string(), UVM_HIGH)


         // encode
         encoder_item.m_code_block_66b = m_encoder_64b66b.encode(
            {encoder_item.m_data0,encoder_item.m_data1,
            encoder_item.m_control0,
            encoder_item.m_control1}
         );

         // update block type of the packet after encoding process has been performed
         encoder_item.m_tx_block_type = m_encoder_64b66b.get_tx_block_format();
         `uvm_info(
            "DRIVER_64b66b_WITH_SCRAMBLER",
            $sformatf("\nEncoder output = %x " , encoder_item.m_code_block_66b),
            UVM_MEDIUM
         )


         // apply scrambling
         // serialize the coded 66bits excluding the 2bit header
         scrmbl_input = {>>{encoder_item.m_code_block_66b[63:0]}};

         // call scrambling function on the bit-stream
         scrmbl_output = m_mult_scrambler.scramble(scrmbl_input);

         // update endec_64b66b item field holding the scrambled bits
         encoder_item.m_scrmbl_code_blk = {>>{scrmbl_output}};

         // apply de-scrambling
         descrmbl_output = m_mult_descrambler.descramble(scrmbl_output);

         // update endec_64b66b item field holding the descrambled bits
         encoder_item.m_descrmbl_code_blk = {>>{descrmbl_output}};

         `uvm_info(
            "DRIVER_64b66b_WITH_SCRAMBLER",
            $sformatf(
               "\nScrambler ouput %x\nDescranbler output %x\n",
               encoder_item.m_scrmbl_code_blk,
               encoder_item.m_descrmbl_code_blk
            ),
            UVM_MEDIUM
         )


         // check scrambler input is the same with descrambler output
         assert (encoder_item.m_code_block_66b[63:0] == encoder_item.m_descrmbl_code_blk) else
            `uvm_error(
               "DRIVER_64b66b_WITH_SCRAMBLER",
               $sformatf(
                  "\nDifference between scrambler input value %x\nand descrambler output value             %x",
                  encoder_item.m_code_block_66b[63:0],
                  encoder_item.m_descrmbl_code_blk
               )
            )


         // decode
         encoder_item.m_decoded_xgmii_data = m_decoder_64b66b.decode(
            {encoder_item.m_code_block_66b[65:64],
               encoder_item.m_descrmbl_code_blk}
         );
         `uvm_info(
            "DRIVER_64b66b_WITH_SCRAMBLER",
            $sformatf(
               "\Decoder output \ncontrol0 = %x \ndata0    = %x \ncontrol1 = %x \ndata1    = %x \n",
               encoder_item.m_decoded_xgmii_data[71:68],
               encoder_item.m_decoded_xgmii_data[67:36],
               encoder_item.m_decoded_xgmii_data[35:32],
               encoder_item.m_decoded_xgmii_data[31:0]
            ),
            UVM_MEDIUM
         )


         // send item to scoreboard
         m_post_decode_item_ap.write(encoder_item);

         seq_item_port.item_done();
      end
   endtask

endclass

`endif

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
 * MODULE:      endec_8b10b_encoder_sequencer.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This is the implementation file of endec_8b10b pkg
 *              encoder sequencer
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_ENCODER_SEQUENCER_SVH
`define ENDEC_8b10b_VE_ENCODER_SEQUENCER_SVH

/* Encoder sequencer
 */
class endec_8b10b_ve_encoder_sequencer extends uvm_sequencer #(endec_8b10b_ve_encoder_seq_item);
   `uvm_component_utils(endec_8b10b_ve_encoder_sequencer)

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new (input string name, input uvm_component parent);
      super.new(name, parent);
   endfunction

endclass

`endif//ENDEC_8b10b_VE_ENCODER_SEQUENCER_SVH

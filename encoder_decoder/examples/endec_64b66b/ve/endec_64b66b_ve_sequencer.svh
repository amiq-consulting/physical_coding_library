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
 * MODULE:      endec_64b66b_ve_sequencer.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This is the implementation file of endec_64b66b sequencer
 *******************************************************************************/

`ifndef ENDEC_64b66b_VE_SEQUENCER_SVH
`define ENDEC_64b66b_VE_SEQUENCER_SVH

/* Sequencer class
 *
 */
class endec_64b66b_ve_sequencer extends uvm_sequencer #(endec_64b66b_ve_seq_item);
   `uvm_component_utils(endec_64b66b_ve_sequencer)
    
   //constructor
   //@param name - name of the component instance
   //@param parent - parent of the component instance
   function new (string name, uvm_component parent);
      super.new(name, parent);
   endfunction

endclass

`endif//ENDEC_64b66b_VE_SEQUENCER_SVH

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
 * MODULE:      endec_8b10b_ve_encoder_agent.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains encoding agent
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_ENCODER_AGENT_SVH
`define ENDEC_8b10b_VE_ENCODER_AGENT_SVH

/* Encoder agent
 */
class endec_8b10b_ve_encoder_agent extends uvm_agent;
   `uvm_component_utils(endec_8b10b_ve_encoder_agent)

   // driver
   endec_8b10b_ve_encoder_driver m_driver_h;

   // sequencer
   endec_8b10b_ve_encoder_sequencer m_sequencer_h;

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(input string name, input uvm_component parent);
      super.new(name, parent);
   endfunction

   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_sequencer_h = endec_8b10b_ve_encoder_sequencer::type_id::create("m_sequencer_h", this);
      m_driver_h = endec_8b10b_ve_encoder_driver::type_id::create("m_driver_h", this);
   endfunction

   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      m_driver_h.seq_item_port.connect(m_sequencer_h.seq_item_export);
   endfunction

endclass

`endif//ENDEC_8b10b_VE_ENCODER_AGENT_SVH



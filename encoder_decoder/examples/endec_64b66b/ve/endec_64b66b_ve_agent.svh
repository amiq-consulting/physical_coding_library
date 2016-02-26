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
 * MODULE:      endec_64b66b_ve_agent.sv
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This file contains the agent component of the endec_64b66b pkt
 *******************************************************************************/

`ifndef ENDEC_64b66b_VE_AGENT_SVH
`define ENDEC_64b66b_VE_AGENT_SVH

/* Agent class
 *
 */
class endec_64b66b_ve_agent extends uvm_agent;
   `uvm_component_utils(endec_64b66b_ve_agent)

   //driver
   endec_64b66b_ve_drv m_driver_64b66b;
   //sequencer
   endec_64b66b_ve_sequencer m_sequencer_64b66b;


   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction


   /* UVM build phase
    * @param phase - current phase
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_driver_64b66b = endec_64b66b_ve_drv::type_id::create("m_driver_64b66b", this);
      m_sequencer_64b66b = endec_64b66b_ve_sequencer::type_id::create("m_sequencer_64b66b", this);
   endfunction


   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      m_driver_64b66b.seq_item_port.connect(m_sequencer_64b66b.seq_item_export);
   endfunction

endclass

`endif//ENDEC_64b66b_VE_AGENT_SVH
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
 * MODULE:      endec_64b66b_ve_env.svh
 * PROJECT:     endec_64b66b
 *
 *
 * Description: This file contains the environment component
 *******************************************************************************/

`ifndef ENDEC_64b66b_VE_ENV_SVH
`define ENDEC_64b66b_VE_ENV_SVH


/* Environment class
 */
class endec_64b66b_ve_env extends uvm_env;
   `uvm_component_utils(endec_64b66b_ve_env)

   // agent
   endec_64b66b_ve_agent m_agent_64b66b;

   // scoreboard
   endec_64b66b_ve_scoreboard m_sb_64b66b;

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

      // instantiate the agent
      m_agent_64b66b = endec_64b66b_ve_agent::type_id::create("m_agent_64b66b", this);

      // instantiate the scoreboard
      m_sb_64b66b = endec_64b66b_ve_scoreboard::type_id::create("m_sb_64b66b", this);
   endfunction

   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      // connect driver uvm_analysis_port to the scoreboard anlysis_port_imp
      m_agent_64b66b.m_driver_64b66b.m_post_decode_item_ap.connect(m_sb_64b66b.m_decoded_item_ap);
   endfunction

endclass

`endif//ENDEC_64b66b_VE_ENV_SVH

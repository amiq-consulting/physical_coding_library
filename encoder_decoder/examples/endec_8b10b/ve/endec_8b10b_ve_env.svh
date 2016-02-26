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
 * MODULE:      endec_8b10b_ve_env.svgh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains the environment component
 *****************************************************************************/

`ifndef ENDEC_8b10b_VE_ENV_SVH
`define ENDEC_8b10b_VE_ENV_SVH

/* Environment class
 */
class endec_8b10b_ve_env extends uvm_env;
   `uvm_component_utils(endec_8b10b_ve_env)

   // decoder agent
   endec_8b10b_ve_decoder_agent m_dec_agent;

   // encoder agent
   endec_8b10b_ve_encoder_agent m_enc_agent;

   // scoreboard
   endec_8b10b_ve_scb m_scb_8b10b;


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

      m_dec_agent = endec_8b10b_ve_decoder_agent::type_id::create("m_dec_agent", this);

      m_enc_agent = endec_8b10b_ve_encoder_agent::type_id::create("m_enc_agent", this);

      //instantiate the scoreboard
      m_scb_8b10b = endec_8b10b_ve_scb::type_id::create("m_scb_8b10b", this);
   endfunction


   /* UVM connect phase
    * @param phase - current phase
    */
   virtual function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);

      m_enc_agent.m_driver_h.m_dec_seqr_put_port.connect(m_dec_agent.m_sequencer_h.m_port);

      //connect encoder and decoder driver with scoreboard
      m_enc_agent.m_driver_h.m_symb_8b_analysis_port.connect(m_scb_8b10b.m_encoder_drv_ap);
      m_dec_agent.m_driver_h.m_symb_8b_analysis_port.connect(m_scb_8b10b.m_decoder_drv_ap);

   endfunction

endclass

`endif//ENDEC_8b10b_VE_ENV_SVH




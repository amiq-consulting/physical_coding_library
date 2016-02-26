
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
 * MODULE:      descrambler_multiplicative.svh
 * PROJECT:     scrambler_descrambler
 *
 *
 * Description: This is the implementation file of the multiplicative descrambler,
 *              part of the scrambler_descrambler package
 *******************************************************************************/


`ifndef DESCRAMBLER_MULTIPLICATIVE_SVH
`define DESCRAMBLER_MULTIPLICATIVE_SVH


/* Class implementing multiplicative descrambler function
 * @param ORDER   : the order of the polynomial
 * @param TAPS_IN : value of taps of the polynomial     
 */
class descrambler_multiplicative #(int ORDER = 0, bit[ORDER-1:0] TAPS_IN = 0) extends uvm_object;
   `uvm_object_param_utils(descrambler_multiplicative #(ORDER, TAPS_IN))


   // shift registers for descrambler
   local bit[ORDER-1:0] m_lfsr_descrambler;
   // taps corresponding to the generating polynomial
   local bit[ORDER-1:0] m_taps;


   /* Constructor
    * @param name : name for this component instance
    */
   function new(input string name = "");
      super.new(name);
      this.m_taps = TAPS_IN;
   endfunction


   /* Descramble function
    * @param a_bs_in : current bit input
    * @return the descrambled bit-stream output
    */
   virtual function bs_t descramble(input bs_t a_bs_in);
      bs_t bs_out;


      bs_out = new[a_bs_in.size()];


      foreach (a_bs_in[iter]) begin
         // output the vector with the values inside the taps
         bit[63:0] taps_out = m_lfsr_descrambler & m_taps;

         byte unsigned num_of_ones = $countones(taps_out);

         bs_out[iter] = a_bs_in[iter] + (num_of_ones%2);

         m_lfsr_descrambler <<= 1;
         m_lfsr_descrambler[0] = a_bs_in[iter];
      end


      return bs_out;
   endfunction


endclass

`endif

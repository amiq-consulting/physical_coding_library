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
 * MODULE:      scrambler_descrambler_additive.svh
 * PROJECT:     scrambler_descrambler
 *
 *
 * Description: This is the implementation file of the additive scrambler
 *              and descrambler part of the scrambler_descrambler package
 *******************************************************************************/


`ifndef SCRAMBLER_DESCRAMBLER_ADDITIVE_SVH
`define SCRAMBLER_DESCRAMBLER_ADDITIVE_SVH


/* Class implementing the additive scrambler/descrambler
 * Both Additive scrambler and  descrambler have the same implementation
 * @param ORDER   : the order of the polynomial
 * @param TAPS_IN : value of taps of the polynomial
 */
class scrambler_descrambler_additive#(int ORDER = 0, bit[ORDER-1:0] TAPS_IN = 0) extends uvm_object;
  `uvm_object_param_utils(scrambler_descrambler_additive#(ORDER,TAPS_IN))

  // shift register
  local bit[ORDER-1:0] m_lfsr;
  // taps corresponding to the generating polynomial
  local bit[ORDER-1:0] m_taps;


  /* Constructor
   * @param name : name for this component instance
   */
  function new(input string name = "");
    super.new(name);
    this.m_taps = TAPS_IN;
  endfunction


  /* Function that load the shift register with initial value
   * @param a_load_value : value to load the shift register with
   */
  virtual function void load_lfsr (bit[ORDER-1:0] a_load_value);
    this.m_lfsr = a_load_value;
  endfunction


  /* Function updating the lfsr
   *
   */
  local function void update_lfsr ();
    // holds the number of taps that participate in the
    // polynomial and have value 1
    byte unsigned num_of_ones;
    // result vector of and-ing together the polynomial tap vector
    // with the value of the lfsr
    bit[ORDER-1:0] taps_out;

    taps_out = m_lfsr & m_taps;
    num_of_ones = $countones(taps_out);
    m_lfsr <<= 1;
    m_lfsr[0] = (num_of_ones%2);
  endfunction


  /* Function applying scrambling on input using the shift register
   * @param a_bs_in : bit-stream input
   * @return bit-stream out
   */
  virtual function bs_t scramble (input bs_t a_bs_in);
    return scramble_or_descramble(a_bs_in);
  endfunction
  
  /* Function applying descrambling on input using the shift register
   * @param a_bs_in : bit-stream input
   * @return bit-stream out
   */
  virtual function bs_t descramble (input bs_t a_bs_in);
    return scramble_or_descramble(a_bs_in);
  endfunction

  /* Function applying scrambling/descrambling on input using the shift register
   * same function performs both operations
   * @param a_bs_in : bit-stream input
   * @return bit-stream out
   */
  virtual protected function bs_t scramble_or_descramble (input bs_t a_bs_in);
    bs_t bs_out;
    bs_out = new[a_bs_in.size()];

    foreach (a_bs_in[iter]) begin
      update_lfsr();
      bs_out[iter] = m_lfsr[0] + a_bs_in[iter];
    end

    return bs_out;
  endfunction


endclass

`endif
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
 * MODULE:      endec_8b10b_coverage.svh
 * PROJECT:     endec_8b10b
 *
 *
 * Description: This file contains agent coverage collector
 *****************************************************************************/

`ifndef ENDEC_8b10b_COVERAGE_SVH
`define ENDEC_8b10b_COVERAGE_SVH


/* Coverage component
 */
class endec_8b10b_coverage extends uvm_component;
   `uvm_component_utils(endec_8b10b_coverage)


   //analysis import delivering the coverage item
   uvm_analysis_imp#(endec_8b10b_cov_data, endec_8b10b_coverage) m_cov_data_ap;


   //if set means the byte to be encoded is a control symbol
   bit m_is_k_symbol;

   //received 8b10b encoded symbol
   bit[9:0] m_symbol_10b;

   //received un-encoded/decoded data byte
   bit[7:0] m_symbol_8b;

   //holds the disparity throughout the encoding process, initial value is -1
   int m_running_disp;

   //previous symbol received
   bit[3:0] m_prev_symbol_4b;

   // Cover group for the 8bit symbol
   covergroup symbol_8b_cov;

      option.per_instance = 1;

      // Cover type of symbol : data or control
      k_d_symbols : coverpoint m_is_k_symbol {
         bins k_symbol = {1};
         bins d_symbol = {0};
      }

      // Cover transitions between types of symbol
      k_d_symb_trans : coverpoint m_is_k_symbol {
         bins transitions[] = (0,1=>0,1);
      }

      // Cover the running disparity
      disparity : coverpoint m_running_disp {
         bins negative = {-1};
         bins positive = {1};
      }

      // Cover the disparity transitions
      disp_trans : coverpoint m_running_disp {
         bins transitions[] = (-1,1=>-1,1);
      }

      // Cover the 8bit data symbol
      symbol_8b : coverpoint m_symbol_8b {
         bins values[] = {[8'h0:8'hFF]};
      }

      // Cover the 8bit input symbol crossed with type of the symbol
      crs_k_d_value : cross symbol_8b, k_d_symbols {
         ignore_bins ignore = !binsof(symbol_8b) intersect {
            K_28_0_8B,
            K_28_1_8B,
            K_28_2_8B,
            K_28_3_8B,
            K_28_4_8B,
            K_28_5_8B,
            K_28_6_8B,
            K_28_7_8B,
            K_23_7_8B,
            K_27_7_8B,
            K_29_7_8B,
            K_30_7_8B} && binsof(k_d_symbols) intersect {1};
      }

      // Cover the 8bit symbol crossed with type of symbol and disparity
      crs_k_d_val_disp :cross symbol_8b, k_d_symbols, disparity {
         ignore_bins ignore = !binsof(symbol_8b) intersect {
            K_28_0_8B,
            K_28_1_8B,
            K_28_2_8B,
            K_28_3_8B,
            K_28_4_8B,
            K_28_5_8B,
            K_28_6_8B,
            K_28_7_8B,
            K_23_7_8B,
            K_27_7_8B,
            K_29_7_8B,
            K_30_7_8B} && binsof(k_d_symbols) intersect {1} && binsof(disparity) intersect {-1, 1};
      }

   endgroup

   // Cover group for the 10bit symbol
   covergroup symbol_10b_cov;

      option.per_instance = 1;

      // Cover the 6bit code group
      symbol_6b : coverpoint m_symbol_10b[9:4] {
         bins symbol_6b[] = {
            D_00_6B_N,
            D_00_6B_P,
            D_01_6B_N,
            D_01_6B_P,
            D_02_6B_N,
            D_02_6B_P,
            D_03_6B,
            D_04_6B_N,
            D_04_6B_P,
            D_05_6B,
            D_06_6B,
            D_07_6B_N,
            D_07_6B_P,
            D_08_6B_N,
            D_08_6B_P,
            D_09_6B,
            D_10_6B,
            D_11_6B,
            D_12_6B,
            D_13_6B,
            D_14_6B,
            D_15_6B_N,
            D_15_6B_P,
            D_16_6B_N,
            D_16_6B_P,
            D_17_6B,
            D_18_6B,
            D_19_6B,
            D_20_6B,
            D_21_6B,
            D_22_6B,
            D_23_6B_N,
            D_23_6B_P,
            D_24_6B_N,
            D_24_6B_P,
            D_25_6B,
            D_26_6B,
            D_27_6B_N,
            D_27_6B_P,
            D_28_6B,
            D_29_6B_N,
            D_29_6B_P,
            D_30_6B_N,
            D_30_6B_P,
            D_31_6B_N,
            D_31_6B_P,
            K_28_6B_N,
            K_28_6B_P};
         illegal_bins all_other = default;
      }

      // Cover the 4bit code group
      symbol_4b : coverpoint m_symbol_10b[3:0] {
         bins symbol_4b[] = {
            D_X_0_4B_N,
            D_X_0_4B_P,
            D_X_1_4B,
            D_X_2_4B,
            D_X_3_4B_N,
            D_X_3_4B_P,
            D_X_4_4B_N,
            D_X_4_4B_P,
            D_X_5_4B,
            D_X_6_4B,
            D_X_P7_4B_N,
            D_X_P7_4B_P,
            D_X_A7_4B_N,
            D_X_A7_4B_P};
         illegal_bins all_other = default;
      }

      // Cover the 6bit code group crossed with the 4bit code group
      crs_6b_x_4b : cross symbol_6b, symbol_4b {
         ignore_bins all_other = (binsof (symbol_6b) intersect {
               D_07_6B_N,
               D_00_6B_P,
               D_01_6B_P,
               D_02_6B_P,
               D_04_6B_P,
               D_08_6B_P,
               D_15_6B_P,
               D_16_6B_P,
               D_23_6B_P,
               D_24_6B_P,
               D_27_6B_P,
               D_29_6B_P,
               D_30_6B_P,
               D_31_6B_P,
               K_28_6B_P
            } && !binsof (symbol_4b) intersect {
               D_X_0_4B_N,
               D_X_1_4B,
               D_X_2_4B,
               D_X_3_4B_N,
               D_X_4_4B_N,
               D_X_5_4B,
               D_X_6_4B,
               D_X_P7_4B_N,
               D_X_A7_4B_N}) ||
         (binsof (symbol_6b) intersect {
               D_07_6B_P,
               D_00_6B_N,
               D_01_6B_N,
               D_02_6B_N,
               D_04_6B_N,
               D_08_6B_N,
               D_15_6B_N,
               D_16_6B_N,
               D_23_6B_N,
               D_24_6B_N,
               D_27_6B_N,
               D_29_6B_N,
               D_30_6B_N,
               D_31_6B_N,
               K_28_6B_N
            }  &&
            !binsof (symbol_4b) intersect {
               D_X_0_4B_P,
               D_X_1_4B,
               D_X_2_4B,
               D_X_3_4B_P,
               D_X_4_4B_P,
               D_X_5_4B,
               D_X_6_4B,
               D_X_P7_4B_P,
               D_X_A7_4B_P
            }) ||
         (binsof (symbol_6b) intersect {D_17_6B, D_18_6B, D_20_6B} &&
            binsof (symbol_4b) intersect {D_X_A7_4B_P, D_X_P7_4B_N, D_X_P7_4B_P}) ||
         (binsof (symbol_6b) intersect {D_11_6B, D_13_6B, D_14_6B} &&
            binsof (symbol_4b) intersect {D_X_A7_4B_N, D_X_P7_4B_N, D_X_P7_4B_P}) ||
         (!binsof (symbol_6b) intersect {D_17_6B, D_18_6B, D_20_6B} &&
            binsof (symbol_4b) intersect {D_X_A7_4B_N}) ||
         (!binsof (symbol_6b) intersect {D_11_6B, D_13_6B, D_14_6B} &&
            binsof (symbol_4b) intersect {D_X_A7_4B_P}) ||
         (binsof (symbol_6b) intersect {
               K_28_6B_N,
               K_28_6B_P,
               K_23_6B_N,
               K_23_6B_P,
               K_27_6B_N,
               K_27_6B_P,
               K_29_6B_N,
               K_29_6B_P,
               K_30_6B_N,
               K_30_6B_P}  &&
            !binsof (symbol_4b) intersect {
               K_X_0_4B_N,
               K_X_1_4B_N,
               K_X_2_4B_N,
               K_X_3_4B_N,
               K_X_4_4B_N,
               K_X_5_4B_N,
               K_X_6_4B_N,
               K_X_7_4B_N,
               K_X_0_4B_P,
               K_X_1_4B_P,
               K_X_2_4B_P,
               K_X_3_4B_P,
               K_X_4_4B_P,
               K_X_5_4B_P,
               K_X_6_4B_P,
               K_X_7_4B_P});
      }

      prev_symbol_4b : coverpoint m_prev_symbol_4b {
         option.weight = 0;
         ignore_bins ignore_initial_value = {0};
         ignore_bins ignore_F_value = {15};
      }

      // Cover previous 4bit code group crossed with new 6bit code group
      crs_prev_4b_x_6b : cross prev_symbol_4b, symbol_6b {
         ignore_bins all_other = (binsof (prev_symbol_4b) intersect {
               D_X_0_4B_P,
               D_X_3_4B_N,
               D_X_4_4B_P,
               D_X_P7_4B_P,
               D_X_A7_4B_P
            } && !binsof (symbol_6b) intersect {
               D_03_6B,
               D_05_6B,
               D_06_6B,
               D_09_6B,
               D_10_6B,
               D_11_6B,
               D_12_6B,
               D_13_6B,
               D_14_6B,
               D_17_6B,
               D_18_6B,
               D_19_6B,
               D_20_6B,
               D_21_6B,
               D_22_6B,
               D_25_6B,
               D_26_6B,
               D_28_6B,
               D_07_6B_N,
               D_00_6B_N,
               D_01_6B_N,
               D_02_6B_N,
               D_04_6B_N,
               D_08_6B_N,
               D_15_6B_N,
               D_16_6B_N,
               D_23_6B_N,
               D_24_6B_N,
               D_27_6B_N,
               D_29_6B_N,
               D_30_6B_N,
               D_31_6B_N,
               K_28_6B_N
            }) ||
         (binsof (prev_symbol_4b) intersect {
               D_X_0_4B_N,
               D_X_3_4B_P,
               D_X_4_4B_N,
               D_X_P7_4B_N,
               D_X_A7_4B_N
            } && !binsof (symbol_6b) intersect {
               D_03_6B,
               D_05_6B,
               D_06_6B,
               D_09_6B,
               D_10_6B,
               D_11_6B,
               D_12_6B,
               D_13_6B,
               D_14_6B,
               D_17_6B,
               D_18_6B,
               D_19_6B,
               D_20_6B,
               D_21_6B,
               D_22_6B,
               D_25_6B,
               D_26_6B,
               D_28_6B,
               D_07_6B_P,
               D_00_6B_P,
               D_01_6B_P,
               D_02_6B_P,
               D_04_6B_P,
               D_08_6B_P,
               D_15_6B_P,
               D_16_6B_P,
               D_23_6B_P,
               D_24_6B_P,
               D_27_6B_P,
               D_29_6B_P,
               D_30_6B_P,
               D_31_6B_P,
               K_28_6B_P
            });
      }
   endgroup

   /* Constructor
    * @param name : name for this component instance
    * @param parent : parent for this component
    */
   function new(input string name, input uvm_component parent);
      super.new(name, parent);

      m_cov_data_ap = new("m_cov_data_ap", this);

      symbol_8b_cov = new();
      symbol_10b_cov = new();
      // set initial values
      m_running_disp = -1;
      m_prev_symbol_4b = 4'b0;

   endfunction


   /* Overwrite function to collect the coverage for 8 bit item
    * @param a_cov_data : coverage item sent for coverage collection
    */
   virtual function void write(input endec_8b10b_cov_data a_cov_data);
      m_symbol_10b = a_cov_data.m_encoded_symb;
      m_symbol_8b  = a_cov_data.m_data;
      m_is_k_symbol = a_cov_data.m_is_k_symbol;


      m_running_disp = a_cov_data.m_post_disp;

      // call sample() functions
      symbol_8b_cov.sample();
      symbol_10b_cov.sample();

      m_prev_symbol_4b = m_symbol_10b[3:0];
   endfunction
//--------------

endclass

`endif//ENDEC_8b10b_COVERAGE_SVH
#!/bin/sh -e


#the default values of the user controlled options
default_run_mode="batch"
default_tool=questa
default_seed=1;

#  not from here
default_test="scrambler_descrambler_multiplicative_test"


default_quit_cnt=0
default_verbosity=UVM_MEDIUM
default_script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
default_script_path="$(cd ${default_script_path}/examples/coding_and_scrambling/scripts/ && pwd )"
default_arch_bits=64

echo ${default_script_path}


# example to run; there are several examples: endec_8b10b, endec_64b66b, scrmb_descrmb_add, scrmb_descrmb_mult, scrmb_descrmb_endec
default_ex_to_run="scrmb_descrmb_endec"


ex_to_run=${default_ex_to_run}
run_mode=${default_run_mode}
tool=${default_tool}
seed=${default_seed}
test=${default_test}
quit_cnt=${default_quit_cnt}
verbosity=${default_verbosity}
script_path=${default_script_path}
ARCH_BITS=${default_arch_bits}



help() {
   echo ""
   echo "Possible values for this script:"
   echo "  -i                                                                       --> run in interactive mode"
   echo "  -ex_to_run                                                               --> specifiy what example to run; it can be: endec_8b10b, endec_64b66b, scrmb_descrmb_add, scrmb_descrmb_mult, scrmb_descrmb_endec"
   echo "  -seed <SEED>                                                             --> specify a particular seed for the simulation (default: ${default_seed})"
   echo "  -test <TEST_NAME>                                                        --> specify a particular test to run (default: ${default_test})"
   echo "  -tool [ius|questa|vcs]                                                   --> specify what simulator to use (default: ${default_tool})"
   echo "  -bit[32|64]                                                              --> specify what architecture to use: 32 or 64 bits (default: ${default_arch_bits} bits)"
   echo "  -quit_cnt                                                                --> specify after how many errors should the test stop (default: ${default_quit_cnt})"
   echo "  -verbosity {UVM_NONE|UVM_LOW|UVM_MEDIUM|UVM_HIGH|UVM_FULL|UVM_DEBUG }]   --> specify the verbosity of a message (default: ${default_uvm_verbosity})"
   echo "  -help                  --> print this message"
   echo ""

}


#use this to register options
options=""

while [ $# -gt 0 ]; do
    case `echo $1 | tr "[A-Z]" "[a-z]"` in
        -seed)
            seed=$2
        ;;
        -tool)
            tool=$2
        ;;
        -test)
            test=$2
        ;;
        -i)
            run_mode="-i"
        ;;
        -help)
            help
            exit 0
        ;;
        -verbosity)
            verbosity=$2
        ;;
        -quit_cnt)
            quit_cnt=$2
        ;;
        -bit32)
            ARCH_BITS=32
        ;;
        -bit64)
            ARCH_BITS=64
        ;;
        -ex_to_run)
            # call the appropriate script
            # reset the scrit path to proj directory
            script_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
            case `echo $2 | tr "[A-Z]" "[a-z]"` in
               endec_8b10b)
                  script_path="$( cd ${script_path}/encoder_decoder/examples/endec_8b10b/scripts/ && pwd )"
                  echo "BEEN HERE !!!"
                  echo ${script_path}
               ;;
               endec_64b66b)
                  script_path="$( cd ${script_path}/encoder_decoder/examples/endec_64b66b/scripts/ && pwd )"
               ;;
               scrmb_descrmb_add)
                  script_path="$( cd ${script_path}/scrambler_descrambler/examples/additive/scripts/ && pwd )"
               ;;
               scrmb_descrmb_mult)
                  script_path="$( cd ${script_path}/scrambler_descrambler/examples/multiplicative/scripts/ && pwd )"
               ;;
               scrmb_descrmb_endec)
                  script_path="$( cd ${script_path}/examples/coding_and_scrambling/scripts/ && pwd )"
               ;;
               *)
                  echo "Invalid option given, exitting."
                  exit 0
               ;;              
            esac
        ;;
        -*)
            echo "Invalid option given, exitting."
            exit 0
        ;;
    esac
    shift
done

test_cmd="-test $test"
if [ $test == $default_test ]; then
  test_cmd=""
fi

options="-seed $seed -tool $tool $test_cmd $run_mode -verbosity $verbosity -quit_cnt $quit_cnt -bits ${ARCH_BITS}"
echo "Running script ${script_path}/run.sh with options: ${options}"

${script_path}/run.sh ${options}

#${script_path}/run.sh -ex_to_run ${ex_to_run} -tool ${tool} -test ${test} -quit_cnt ${quit_cnt} -verbosity ${verbosity}
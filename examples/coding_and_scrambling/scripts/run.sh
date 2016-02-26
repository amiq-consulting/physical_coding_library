#!/bin/sh -e


#the default values of the user controlled options
default_run_mode="batch"
default_tool=ius
default_seed=1;
default_test="endec_64b66b_with_scrambler_test"
default_quit_cnt=0
default_verbosity=UVM_MEDIUM
default_arch_bits=64


run_mode=${default_run_mode}
tool=${default_tool}
seed=${default_seed}
test=${default_test}
quit_cnt=${default_quit_cnt}
verbosity=${default_verbosity}
ARCH_BITS=${default_arch_bits}

export TOP_MODULE_NAME=${DUT_MODULE_NAME}_top
export TOP_FILE_NAME=${TOP_MODULE_NAME}.sv
export TOP_FILE_PATH=${EXAMPLE_DIR}/sv/${TOP_FILE_NAME}

# give direct values to exports
export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../../ && pwd )"
export EXAMPLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

echo $PROJECT_DIR
echo $EXAMPLE_DIR

export TOP_MODULE_NAME=coding_and_scrambling_top
export TOP_FILE_NAME=coding_and_scrambling_top.sv
export TOP_FILE_PATH=${EXAMPLE_DIR}/sv/${TOP_FILE_NAME}

help() {
    echo ""
    echo "Possible options for this script:"
    echo "  -i                                                                      --> run in interactive mode"
    echo "  -seed <SEED>                                                            --> specify a particular seed for the simulation (default: ${default_seed})"
    echo "  -test <TEST_NAME>                                                       --> specify a particular test to run (default: ${default_test})"
    echo "  -tool [ius|questa|vcs]                                                  --> specify what simulator to use (default: ${default_tool})"
    echo "  -quit_cnt                                                               --> specify after how many errors should the test stop (default: ${default_quit_cnt})"
    echo "  -verbosity {UVM_NONE|UVM_LOW|UVM_MEDIUM|UVM_HIGH|UVM_FULL|UVM_DEBUG }]  --> specify the verbosity of a message (default: ${default_uvm_verbosity})"
    echo "  -bit[32|64]                                                             --> specify what architecture to use: 32 or 64 bits (default: ${default_arch_bits} bits)"
    echo "  -help                                                                   --> print this message"
    echo ""
}

run_with_ius_test() {
    EXTRA_OPTIONS=" ${EXTRA_OPTIONS} "

    if [ ${ARCH_BITS} -eq 64 ]; then
      EXTRA_OPTIONS=" ${EXTRA_OPTIONS} -64bit"
    fi
    
    if [ "$run_mode" = "interactive" ]; then
        rm -rf ncsim_cmds.tcl
        touch ncsim_cmds.tcl

        echo "database -open waves -into waves.shm -default"     >> ncsim_cmds.tcl
        echo "probe -create ${TOP_MODULE_NAME}  -depth all -tasks -functions -uvm -packed 4k -unpacked 16k -all" >> ncsim_cmds.tcluntil it sleeps metallica        

        EXTRA_OPTIONS=" ${EXTRA_OPTIONS} -gui -input ncsim_cmds.tcl "
    else
        EXTRA_OPTIONS=" ${EXTRA_OPTIONS} -exit "
    fi

    irun -f ${PROJECT_DIR}/examples/coding_and_scrambling/scripts/options_ius.f -svseed ${seed} +UVM_TESTNAME=${test} +UVM_VERBOSITY=${verbosity} +UVM_MAX_QUIT_COUNT=${quit_cnt} ${EXTRA_OPTIONS}
}

run_with_vcs_test() {
    EXTRA_OPTIONS=" ${EXTRA_OPTIONS} "

    if [ "$run_mode" = "interactive" ]; then
        EXTRA_OPTIONS=" ${EXTRA_OPTIONS}  -gui "
    fi

    if [ ${ARCH_BITS} -eq 64 ]; then
      EXTRA_OPTIONS=" ${EXTRA_OPTIONS} -full64"
    fi
    
    vcs -ntb_opts uvm -f ${PROJECT_DIR}/examples/coding_and_scrambling/scripts/options_vcs.f +ntb_random_seed=${seed} +UVM_TESTNAME=${test} +UVM_VERBOSITY=${verbosity} +UVM_MAX_QUIT_COUNT=${quit_cnt} -R ${EXTRA_OPTIONS}

}

run_with_questa_test() {
    vlib work
    vlog -f ${PROJECT_DIR}/examples/coding_and_scrambling/scripts/options_vlog.f

    EXTRA_OPTIONS=" ${EXTRA_OPTIONS} "

    if [ "$run_mode" != "interactive" ]; then
        rm -rf vsim_cmds.do
        touch vsim_cmds.do

        echo "run -all; exit"     >> vsim_cmds.do

        EXTRA_OPTIONS=" ${EXTRA_OPTIONS}  -do vsim_cmds.do -c "
    fi

    vsim -${ARCH_BITS} -novopt ${TOP_MODULE_NAME} -sv_seed ${seed} +UVM_TESTNAME=${test} +UVM_VERBOSITY=${verbosity} +UVM_MAX_QUIT_COUNT=${quit_cnt} ${EXTRA_OPTIONS}
}

while [ $# -gt 0 ]; do    
    case `echo $1 | tr "[A-Z]" "[a-z]"` in
        -seed)
            seed=$2
        ;;
        -tool)
            tool=$2
        ;;
        -test)
        echo "STOP HERE"
        echo $2
        read -p "Should take the non-default test" user_input        
            test=$2
        ;;
        -verbosity)
            verbosity=$2
        ;;
        -quit_cnt)
            quit_cnt=$2
        ;;
        -i)
            run_mode=interactive
        ;;
        -bits)
            ARCH_BITS=$2
        ;;
        -help)
            help
            exit 0
        ;;
    esac
    shift
done

export ARCH_BITS=${ARCH_BITS}

case $tool in
    ius)
        echo "Selected tool: IUS..."
    ;;
    vcs)
        echo "Selected tool: VCS..."
    ;;
    questa)
        echo "Selected tool: Questa..."
    ;;
    *)
        echo "Illegal option for tool: $tool"
        exit 1;
    ;;
esac


sim_dir=`pwd`/sim_${test}
echo "Start running ${test} test in ${sim_dir}";
rm -rf ${sim_dir};
mkdir ${sim_dir};
cd ${sim_dir};
run_with_${tool}_test

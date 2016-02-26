#!/bin/sh -e

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../../ && pwd )"
export EXAMPLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

#the default values of the user controlled options
default_test="endec_8b10b_tests_all_k_test"

export ENDEC_TYPE=endec_8b10b
export DUT_MODULE_NAME=endec_8b10b

${PROJECT_DIR}/examples/common/scripts/run.sh -default_test ${default_test} $@
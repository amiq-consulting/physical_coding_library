#!/bin/sh -e

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../../ && pwd )"
export EXAMPLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

#the default values of the user controlled options
default_test="endec_64b66b_tests_legal_seq_test"

export ENDEC_TYPE=endec_64b66b
export DUT_MODULE_NAME=endec_64b66b

${PROJECT_DIR}/examples/common/scripts/run.sh -default_test ${default_test} $@
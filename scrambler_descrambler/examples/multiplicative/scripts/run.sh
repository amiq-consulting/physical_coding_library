#!/bin/sh -e

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../../../ && pwd )"
export EXAMPLE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd ../ && pwd )"

#the default values of the user controlled options
default_test="scrambler_descrambler_multiplicative_test"

export DUT_MODULE_NAME=scrambler_descrambler_multiplicative

${PROJECT_DIR}/examples/common/scripts/run.sh -default_test ${default_test} $@
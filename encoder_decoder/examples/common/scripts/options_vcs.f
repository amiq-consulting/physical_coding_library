-sverilog

+incdir+${PROJECT_DIR}/sv/${ENDEC_TYPE}

+incdir+${EXAMPLE_DIR}/
+incdir+${EXAMPLE_DIR}/ve
+incdir+${EXAMPLE_DIR}/tests

${PROJECT_DIR}/sv/${ENDEC_TYPE}/${ENDEC_TYPE}_pkg.sv
${EXAMPLE_DIR}/ve/${ENDEC_TYPE}_ve_pkg.sv
${EXAMPLE_DIR}/tests/${ENDEC_TYPE}_tests_pkg.sv
${TOP_FILE_PATH}
-top ${TOP_MODULE_NAME}
-timescale=1ns/1ps
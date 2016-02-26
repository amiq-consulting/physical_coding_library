+incdir+${PROJECT_DIR}/sv/
+incdir+${PROJECT_DIR}/encoder_decoder/sv/endec_64b66b/
+incdir+${PROJECT_DIR}/encoder_decoder/examples/endec_64b66b/
+incdir+${PROJECT_DIR}/encoder_decoder/examples/endec_64b66b/ve
+incdir+${PROJECT_DIR}/encoder_decoder/examples/endec_64b66b/tests
+incdir+${PROJECT_DIR}/scrambler_descrambler/sv/

+incdir+${EXAMPLE_DIR}/
+incdir+${EXAMPLE_DIR}/sv
+incdir+${EXAMPLE_DIR}/tests

-linedebug
-uvmlinedebug
+uvm_set_action="*,_ALL_,UVM_ERROR,UVM_DISPLAY|UVM_STOP"
-uvm
-access rw
-sv
-covoverwrite
-coverage all
+UVM_NO_RELNOTES
-DSC_INCLUDE_DYNAMIC_PROCESSES
+define+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
-timescale 1ns/1ps

${PROJECT_DIR}/encoder_decoder/sv/endec_64b66b/endec_64b66b_pkg.sv
${PROJECT_DIR}/encoder_decoder/examples/endec_64b66b/ve/endec_64b66b_ve_pkg.sv
${PROJECT_DIR}/encoder_decoder/examples/endec_64b66b/tests/endec_64b66b_tests_pkg.sv
${PROJECT_DIR}/scrambler_descrambler/sv/scrambler_descrambler_pkg.sv

${TOP_FILE_PATH}

+incdir+${PROJECT_DIR}/sv/${ENDEC_TYPE}

+incdir+${EXAMPLE_DIR}/
+incdir+${EXAMPLE_DIR}/ve
+incdir+${EXAMPLE_DIR}/tests


-${ARCH_BITS}bit
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
${PROJECT_DIR}/sv/${ENDEC_TYPE}/${ENDEC_TYPE}_pkg.sv
${EXAMPLE_DIR}/ve/${ENDEC_TYPE}_ve_pkg.sv
${EXAMPLE_DIR}/tests/${ENDEC_TYPE}_tests_pkg.sv
${TOP_FILE_PATH}

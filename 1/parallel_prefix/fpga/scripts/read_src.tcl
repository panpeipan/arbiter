#read source (RTL & IP & CONTRAINTS)
read_verilog [glob $SOURCE_DIR/*.v]
#read_verilog [glob $SOURCE_DIR/*.vh]
read_ip      [glob $IP_LIB/sysclk_wiz/*.xci]
read_xdc     [glob $CONSTRS_DIR/*.xdc]

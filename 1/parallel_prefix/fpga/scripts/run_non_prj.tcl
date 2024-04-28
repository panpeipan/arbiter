#################################################
# vivado FPGA environment configuration
#################################################
set DATE         [clock format [clock seconds] -format {%m%d%H}]
set DEVICE       xc7z020
set PACKAGE      clg400 
set SPEED        -1
#set PART         $DEVICE$PACKAGE$SPEED
set PART         xc7k325tffg676-2 
set PRJ_NAME     colorbar_display_prj
#################################
set top          breath_led     
#set SOURCE_DIR   /home/ICer/ic_prjs/colorbar_display_prj/fpga 
set SCRIPT_DIR    [file dirname [file normalize [info script]]]
set COMMON_DIR    [file dirname $SCRIPT_DIR]
set FPGA_DIR      [file dirname $COMMON_DIR]
set CONSTRS_DIR   [file join $COMMON_DIR constrs]
set IP_LIB        [file join $COMMON_DIR ip_lib]
set SOURCE_DIR    [file join $COMMON_DIR rtl   ]
set SIMULATE_DIR  [file join $COMMON_DIR testbench]
set WORK_FILE     [file join $FPGA_DIR work]
set SynOutputDir  [file join $FPGA_DIR SynOutputDir]
file mkdir -force $SynOutputDir 
set ImplOutputDir [file join $FPGA_DIR ImplOutputDir]
file mkdir -force $ImplOutputDir 
################################################
#directive
################################################
set synDtv  default
set synDcp  1
set synAna  1
set synIPen 0

set optDtv  default
set optDcp  1
set optAna  1

set placeDtv default 
set placeDcp 1
set placeAna 1

set physOptDtvAp default
set physOptApDcp 1
set physOptApAna 1

set routeDtv  default 
set routeDcp  1
set routeAna  1

#布局后物理优化 (可选)
set physOptArEn 0 
set physOptDtvAr default 
set physOptArDcp 1
set physOptArAna 1

set_param general.maxThreads 8
#set_property verilog_define {FPGA_SYN=1} [get_filesets sources_1]
#################################################
#source tcl 
#################################################
source read_src.tcl
if { $synIPen == 1 } { source synth_ip.tcl }
source ns.tcl 
source synth.tcl 
source impl.tcl 
source bitstream.tcl 

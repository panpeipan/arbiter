#################################################
# vivado FPGA environment configuration
#################################################
set DATE         [clock format [clock seconds] -format {%m%d%H}]
set DEVICE       xc7z020
set PACKAGE      clg400 
set SPEED        -1
set PART         $DEVICE$PACKAGE$SPEED
#set PART         xc7k325tffg676-2 
set PRJ_NAME     [file tail [file dirname [file dirname [pwd]]]]
set top           breath_led
#set SOURCE_DIR   /home/ICer/ic_prjs/colorbar_display_prj/fpga 
set SCRIPT_DIR    [file dirname [file normalize [info script]]]
set COMMON_DIR    [file dirname $SCRIPT_DIR]
set FPGA_DIR      [file dirname $COMMON_DIR]
set CONSTRS_DIR   [file join $COMMON_DIR constrs]
set IP_LIB        [file join $COMMON_DIR ip_lib]
set SOURCE_DIR    [file join $COMMON_DIR rtl   ]
set SIMULATE_DIR  [file join $COMMON_DIR testbench]
set WORK_FILE     [file join $FPGA_DIR work]
if {[glob -nocomplain $WORK_FILE/* ] != ""} {
    file delete -force {*}[glob -nocomplain $WORK_FILE/*]
}
#################################################
# vivado FPGA project_create
#################################################
create_project -force $PRJ_NAME $WORK_FILE -part $PART 


#添加用户自定义IP路径 
#set_property ip_repo_paths ../libs/sysclk_wiz [current_project]
#对生成的sources_1RTL文件-宏定义 
set_property verilog_define {FPGA_SYN=1} [get_filesets sources_1]
#set max threads
set_param general.maxThreads 8


add_files         [glob $SOURCE_DIR/*.v]
#add_files         [glob $SOURCE_DIR/*.vh]
#add_files         [glob $IP_LIB/*/*.xci] 
#add_files         [glob $SCRIPT_DIR/*.xdc]
#update_compile_order -fileset source_1 
#
#set_property strategy Flow_Areaoptimized_high [get_runs synth_1]
#set_property strategy Performance_Explore [get_runs impl_1]
#
launch_runs synth_1
wait_on_run synth_1
#launch_runs impl_1 -to_step write_bitstream 
#wait_on_run impl_1  

start_gui 

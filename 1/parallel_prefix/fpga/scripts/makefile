all:clcs find com sim verdi
find:
	find -name "*.v" > filelist.f
clcs:
	rm -rf csrc *.log *.key *simv* *.vpd *DVE
	rm -rf verdiLog *.fsdb *.bak *.conf *.rc *.logquit
	rm -rf *.f work *.dir xvlog.pb
com:
	vcs -full64 -R +v2k -sverilog -debug_access+all -timescale=1ns/10ps \
		-f filelist.f -l ./output.log -fsdb +define+FSDB 
sim:
	./simv -l sim.log
verdi:
	verdi -f filelist.f -ssf *.fsdb -nologo &
rcom:
	vcs -full64 -R -fsdb +define+FSDB -f filelist.f

#################################################################
clcp:
	rm  ../../work -rf *.cache *.hw *.sim *.ip_user_files *.runs
	rm  ../../work -f *.jou *.log *.txt *.xpr  
	mkdir ../../work
btnp:
	vivado -mode batch -source ./run_non_prj.tcl 
#   vivado tcl batch mode
#   -mode batch               tcl batch mode
#   -tclargs "ARGS_NUM0=1011" 用于值的声明
#   -source  ./xx/xxx.tcl     tcl脚本源声明
#   下属操作为PROJECT模式下的，non-project模式下没有xpr等类似规范的工程流

btp:
	vivado -mode batch -source ./run_prj.tcl

open: 
	vivado -source open_project ./*.xpr 
#1  vivado -mode tcl                     
#   该模式下，为直接调用vivado自带的TCL SHELL （还有一个比较麻烦,没有展示)
#2  vivado -mode gui 
#   该模式就算传统的用户交互GUI界面模式
#3  vivado -mode batch -source ./xxxx.tcl 
#   该模式是批处理模式，可以用于project模式和non-project模式
#   对于此种方法为真谛
#   对于project模式相当于TCL指令下的GUI操作，会有.xpr可执行文件产生，可以用于IP核的创建
#   对于non-project模式，更自由/更迅速 
saveip:
	cp -rf ../../work/*.srcs/sources_1/ip/* ../ip_lib/ 

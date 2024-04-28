#此MAKEFILE 脚本文件是用于对RTL模块功能的单独验证
all:clc_sim find com sim verdi
find:
	find ../rtl ../testbench -name "*.v" > filelist.f 
clc_sim:
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



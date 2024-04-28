debImport "-f" "filelist.f"
debLoadSimResult \
           /home/ICer/ic_prjs/parallel_prefix_round_robin_arbiter/fpga/testbench/tb_top.fsdb
wvCreateWindow
srcHBSelect "tb_pprr_arbiter.u0" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_pprr_arbiter.u0" -delim "."
srcHBSelect "tb_pprr_arbiter.u0" -win $_nTrace1
srcSelect -signal "i_clk" -line 6 -pos 1 -win $_nTrace1
srcSelect -signal "i_rstn" -line 7 -pos 1 -win $_nTrace1
srcSelect -signal "i_req" -line 8 -pos 1 -win $_nTrace1
srcSelect -signal "o_grant" -line 10 -pos 1 -win $_nTrace1
srcSelect -signal "o_ag" -line 11 -pos 1 -win $_nTrace1
srcSelect -signal "i_prior" -line 17 -pos 1 -win $_nTrace1
wvAddSignal -win $_nWave2 "/tb_pprr_arbiter/u0/i_clk" \
           "/tb_pprr_arbiter/u0/i_rstn" "/tb_pprr_arbiter/u0/i_req\[7:0\]" \
           "/tb_pprr_arbiter/u0/o_grant\[7:0\]" "/tb_pprr_arbiter/u0/o_ag" \
           "/tb_pprr_arbiter/u0/i_prior\[7:0\]"
wvSetPosition -win $_nWave2 {("G1" 0)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1/u0" 0)}
wvAddSubGroup -win $_nWave2 -holdpost {u0}
wvAddSignal -win $_nWave2 "/tb_pprr_arbiter/u0/i_clk" \
           "/tb_pprr_arbiter/u0/i_rstn" "/tb_pprr_arbiter/u0/i_req\[7:0\]" \
           "/tb_pprr_arbiter/u0/o_grant\[7:0\]" "/tb_pprr_arbiter/u0/o_ag"
wvSetPosition -win $_nWave2 {("G1/u0" 0)}
wvSetPosition -win $_nWave2 {("G1/u0" 5)}
wvSetCursor -win $_nWave2 369.010562 -snap {("G2" 0)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvSetCursor -win $_nWave2 4717.600338 -snap {("G2" 0)}
wvSelectGroup -win $_nWave2 {G2}
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSelectSignal -win $_nWave2 {( "G1" 6 )} 
wvSetPosition -win $_nWave2 {("G1" 6)}
wvExpandBus -win $_nWave2 {("G1" 6)}
wvSetPosition -win $_nWave2 {("G1/u0" 5)}
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvZoomOut -win $_nWave2
wvScrollDown -win $_nWave2 0
wvScrollDown -win $_nWave2 0
wvSelectGroup -win $_nWave2 {G1/u0}
wvCut -win $_nWave2
wvSetPosition -win $_nWave2 {("G1" 14)}
wvSelectSignal -win $_nWave2 {( "G1" 3 )} 
wvSetPosition -win $_nWave2 {("G1" 3)}
wvExpandBus -win $_nWave2 {("G1" 3)}
wvSetPosition -win $_nWave2 {("G1" 22)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSetPosition -win $_nWave2 {("G1" 12)}
wvExpandBus -win $_nWave2 {("G1" 12)}
wvSetPosition -win $_nWave2 {("G1" 30)}
wvSelectSignal -win $_nWave2 {( "G1" 12 )} 
wvSelectSignal -win $_nWave2 {( "G1" 2 )} 
wvSetCursor -win $_nWave2 5826.598608 -snap {("G1" 28)}
wvDisplayGridCount -win $_nWave2 -off
wvGetSignalClose -win $_nWave2
wvReloadFile -win $_nWave2
debExit

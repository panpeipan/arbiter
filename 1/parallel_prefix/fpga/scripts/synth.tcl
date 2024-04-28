#synth_design -top $top -part $PART -directive default
#write_checkpoint -force $SynOutputDir/post_synth
#report_timing_summary -file $SynOutputDir/post_synth_timing_summary.rpt
#report_utilization -file $SynOutputDir/post_synth_util.rpt


set phase synth_design 
set fn post_synth_${DATE} 
synth_design -top $top -part $PART -directive $synDtv 
#gen dcp 
if {$synDcp == 1} {
    ns::gen_dcp $phase $SynOutputDir $fn 
}
if {$synAna == 1} {
    ns::design_analysis $phase $SynOutputDir $fn
}


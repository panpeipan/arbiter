#opt_design -directive $optDirective 
#write_checkpoint -force $ImplOutputDir/post_opt 
#report_timing_summary -file $ImplOutputDir/post_opt_timing_summary.rpt 
#report_utilization -file $ImplOutputDir/post_opt_util.rpt 
#
#place_design -directive $placeDirective 
#write_checkpoint -force $ImplOutputDir/post_place 
#report_timing_summary -file $ImplOutputDir/post_place_timing_summary.rpt 
#report_utilization -file $ImplOutputDir/post_place_util.rpt 
#
#phys_opt_design -directive $physOptDirectiveAp
#write_checkpoint -force $ImplOutputDir/post_phys_opt_ap
#report_timing_summary -file $ImplOutputDir/post_phys_opt_ap_timing_summary.rpt 
#report_utilization -file $ImplOutputDir/post_phys_opt_ap_util.rpt 
#
#route_design -directive $routeDirective 
#write_checkpoint -force $ImplOutputDir/post_route 
#report_timing_summary -file $ImplOutputDir/post_route_timing_summary.rpt
#report_utilization -file $ImplOutputDir/post_route_util.rpt 

#set impl_cmd [list opt_design place_design phys_opt_design route_design phys_opt_design]
#set impl_dtv [list $optDtv $placeDtv $physOptDtvAp $routeDtv $PhysOptDtvAr ]
#set impl_dcp [list $optDcp $placeDcp $physOptApDcp $routeDcp $PhysOptArDcp ]
#set impl_ana [list $optAna $placeAna $physOptApAna $routeAna $PhysOptArAna ]

set impl_cmd [list opt_design place_design phys_opt_design route_design ]
set impl_dtv [list $optDtv $placeDtv $physOptDtvAp $routeDtv ]
set impl_dcp [list $optDcp $placeDcp $physOptApDcp $routeDcp ]
set impl_ana [list $optAna $placeAna $physOptApAna $routeAna ]

foreach i_cmd $impl_cmd i_dtv $impl_dtv i_dcp $impl_dcp i_ana $impl_ana {
    $i_cmd -directive $i_dtv 
    puts "*******$i_cmd is successfully done!********"
    if {$i_dcp==1} {
        ns::gen_dcp $i_cmd $ImplOutputDir post_${i_cmd}_${DATE}
    }
    if {$i_ana==1} {
        ns::design_analysis $i_cmd $ImplOutputDir post_${i_cmd}_${DATE}
    }
}

if {$physOptArEn==1} {
    phys_opt_design -directive $physOptDtvAr 
    if {$PhysOptArDcp==1} {
        ns:gen_dcp phys_opt_design(AR) $ImplOutputDir post_phys_opt_design_Ar_${DATE}
    }
    if {$physOptArAna==1} {
        ns:design_analysis post_phys_opt_design_Ar_${DATE}
    }
}

set power_enable_analysis TRUE
set power_analysis_mode averaged

set search_path         ". /theda21_2/CBDK_IC_Contest/cur/SynopsysDC/db /usr/synopsys/synthesis/cur/libraries/syn"
set link_library	" * slow.db fast.db sram_1024x8_t13_slow_syn.db"

read_verilog		LMFE_syn.v
current_design		LMFE
link

read_parasitics		LMFE.spef  

check_timing 
update_timing
report_timing

check_power
update_power
report_power -hierarchy > vf.rpt

#quit
exit


transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project {C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project/components.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project {C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project/proc.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project {C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project/BCD.v}
vlog -vlog01compat -work work +incdir+C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project {C:/Users/mbcra/Documents/MONASH/main/ECE2072/Project/ece2072_project/proc_tb.v}


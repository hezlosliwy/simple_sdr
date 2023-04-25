#variables
set rtl_dir ./../src/rtl
set sim_dir ./../src/sim
set constrs_dir ./../src/constraints
set vect_dir ./../tb/misc
#Project
create_project -force sdr ./../prj/sdr -part xc7z010clg225-1
# Add various sources to the project
add_files -fileset sources_1 $rtl_dir/
add_files -fileset sim_1 $sim_dir/
add_files -fileset constrs_1 $constrs_dir

set vect_list [glob $vect_dir/*]
foreach x $vect_list {
    add_files -fileset sim_1 $x
}
# Add block design generated modules
add_files -norecurse ./../src/xci/fir_compiler_0.xci
#Change dir to generate temporary files in prj dir
cd ../prj/sdr/

# Add block design
source ./../../src/bd/sdr_bd.tcl
# Create wrapper
make_wrapper -files [get_files ./bd/sdr_bd/sdr_bd.bd] -top
add_files -norecurse ./bd/sdr_bd/hdl/sdr_bd_wrapper.v

quit

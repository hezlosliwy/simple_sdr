# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: /home/sklat/Pulpit/simple_sdr/sdr/vitis/new_app_system/_ide/scripts/debugger_new_app-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source /home/sklat/Pulpit/simple_sdr/sdr/vitis/new_app_system/_ide/scripts/debugger_new_app-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -nocase -filter {name =~"APU*"}
rst -system
after 3000
targets -set -filter {jtag_cable_name =~ "Digilent JTAG-HS3 210299B71D7D" && level==0 && jtag_device_ctx=="jsn-JTAG-HS3-210299B71D7D-13722093-0"}
fpga -file /home/sklat/Pulpit/simple_sdr/sdr/vitis/new_app/_ide/bitstream/sdr_bd_wrapper.bit
targets -set -nocase -filter {name =~"APU*"}
loadhw -hw /home/sklat/Pulpit/simple_sdr/sdr/vitis/sdr_bd_wrapper/export/sdr_bd_wrapper/hw/sdr_bd_wrapper.xsa -mem-ranges [list {0x40000000 0xbfffffff}] -regs
configparams force-mem-access 1
targets -set -nocase -filter {name =~"APU*"}
source /home/sklat/Pulpit/simple_sdr/sdr/vitis/new_app/_ide/psinit/ps7_init.tcl
ps7_init
ps7_post_config
targets -set -nocase -filter {name =~ "*A9*#0"}
dow /home/sklat/Pulpit/simple_sdr/sdr/vitis/new_app/Debug/new_app.elf
configparams force-mem-access 0
bpadd -addr &main

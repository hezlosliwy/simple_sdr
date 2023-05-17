src_dir := ./src/
scripts_dir := ./scripts/
vprj_dir := ./../prj/sdr/

all: vivado_xpr run_vivado

vivado_xpr:
ifneq "$(wildcard $(vprj_dir) )" ""
	@echo "Project already exists"
else
	vivado -mode tcl -source ./vivado.tcl
endif


run_vivado:
	vivado $(vprj_dir)sdr.xpr &

clean:
	rm ./../prj/* -rf
	rm *.log -f
	rm *.jou -f
	rm .Xil -rf
	rm bd -rf
	rm hdl -rf
	rm xsim.dir -rf
	rm xvlog.pb -f

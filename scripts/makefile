src_dir := ./src/
scripts_dir := ./scripts/
vprj_dir := ./../prj/sdr/

vivado_xpr:
	vivado -mode tcl -source ./vivado.tcl

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

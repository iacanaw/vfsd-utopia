vlib work
vmap work work

vlog -work work -sv ../src/uvm_tb/config.sv 
vlog -work work -sv ../src/uvm_tb/definitions.sv
vlog -work work -sv ../src/uvm_tb/atm_cell.sv 
vlog -work work -sv ../src/uvm_tb/utopia.sv
vlog -work work -sv ../src/uvm_tb/driver.sv 
vlog -work work -sv ../src/uvm_tb/seq_of_UNI.sv
vlog -work work -sv ../src/uvm_tb/sequencer.sv
vlog -work work -sv ../src/uvm_tb/cpu_ifc.sv
vlog -work work -sv ../src/uvm_tb/cpu_driver.sv
vlog -work work -sv ../src/uvm_tb/coverage.sv
vlog -work work -sv ../src/uvm_tb/scoreboard.sv 
vlog -work work -sv ../src/uvm_tb/monitor.sv 
vlog -work work -sv ../src/uvm_tb/LookupTable.sv
vlog -work work -sv ../src/uvm_tb/agent.sv
vlog -work work -sv ../src/uvm_tb/environment.sv 
vlog -work work -sv ../src/dut/utopia1_atm_rx.sv 
vlog -work work -sv ../src/dut/utopia1_atm_tx.sv  
vlog -work work -sv ../src/dut/squat.sv 
vlog -work work -sv ../src/uvm_tb/test.sv
vlog -work work -sv ../src/dut/top2.sv 

set NoQuitOnFinish 1

vsim +UVM_TESTNAME=test +UVM_VERBOSITY=UVM_HIGH -novopt work.top

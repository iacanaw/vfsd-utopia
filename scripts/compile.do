vlib work
vmap work work

vlog -work work -sv ../src/uvm_tb2/config.sv 
vlog -work work -sv ../src/uvm_tb2/definitions.sv
vlog -work work -sv ../src/uvm_tb2/atm_cell.sv 
vlog -work work -sv ../src/uvm_tb2/utopia.sv
##vlog -work work -sv ../src/uvm_tb2/driver.sv 
##vlog -work work -sv ../src/uvm_tb2/cpu_ifc.sv
vlog -work work -sv ../src/uvm_tb2/cpu_driver.sv
##vlog -work work -sv ../src/uvm_tb2/environment.sv 
##vlog -work work -sv ../src/uvm_tb2/coverage.sv
##vlog -work work -sv ../src/uvm_tb2/scoreboard.sv 
##vlog -work work -sv ../src/uvm_tb2/monitor.sv 
##vlog -work work -sv ../src/uvm_tb2/generator.sv
vlog -work work -sv ../src/uvm_tb2/LookupTable.sv
vlog -work work -sv ../src/dut/utopia1_atm_rx.sv 
vlog -work work -sv ../src/dut/utopia1_atm_tx.sv  
vlog -work work -sv ../src/dut/squat.sv 
##vlog -work work -sv ../src/uvm_tb2/test.sv
vlog -work work -sv ../src/dut/top2.sv 

vsim -novopt work.top
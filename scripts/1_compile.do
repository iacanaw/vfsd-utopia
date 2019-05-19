vlib work
vmap work work

vlog -work work -sv ../src/uvm_tb/config.sv 
vlog -work work -sv ../src/uvm_tb/definitions.sv
vlog -work work -sv ../src/uvm_tb/atm_cell.sv 
vlog -work work -sv ../src/uvm_tb/utopia.sv
vlog -work work -sv ../src/uvm_tb/driver.sv 
vlog -work work -sv ../src/uvm_tb/cpu_ifc.sv
vlog -work work -sv ../src/uvm_tb/cpu_driver.sv
vlog -work work -sv ../src/uvm_tb/environment.sv 
vlog -work work -sv ../src/uvm_tb/coverage.sv
vlog -work work -sv ../src/uvm_tb/scoreboard.sv 
vlog -work work -sv ../src/uvm_tb/monitor.sv 
vlog -work work -sv ../src/uvm_tb/generator.sv
vlog -work work -sv ../src/uvm_tb/LookupTable.sv
vlog -work work -sv ../src/dut/utopia1_atm_rx.sv 
vlog -work work -sv ../src/dut/utopia1_atm_tx.sv  
vlog -work work -sv ../src/dut/squat.sv 
vlog -work work -sv ../src/uvm_tb/test.sv
vlog -work work -sv ../src/dut/top.sv 

vsim -novopt work.top

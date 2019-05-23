`ifndef AGENT__UVM
`define AGENT__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "atm_cell.sv"
`include "driver.sv"
`include "monitor.sv"

class Agent extends uvm_agent;
	`uvm_component_utils(Agent)

	Driver    drv;
	Sequencer seq;
	Monitor   mon;


`endif
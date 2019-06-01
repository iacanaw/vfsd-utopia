`ifndef SEQUENCER__UVM
`define SEQUENCER__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/atm_cell.sv"

class UNI_cell_Sequencer extends uvm_sequencer#(UNI_cell);
	`uvm_sequencer_utils(UNI_cell_Sequencer)

	function new(string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new

endclass

`endif
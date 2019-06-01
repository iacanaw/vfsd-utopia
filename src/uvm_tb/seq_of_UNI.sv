`ifndef SEQ__UVM
`define SEQ__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/atm_cell.sv"
`include "../src/uvm_tb/sequencer.sv"


class seq_of_UNI extends uvm_sequence #(UNI_cell);
	`uvm_object_utils(seq_of_UNI)
	
	UNI_cell_Sequencer UNI_seq[`RxPorts];

	function new(string name = "");
		super.new(name);
	endfunction : new

	task body;
		repeat(100) begin
			`uvm_do(req);
			/*
			UNI_cell new_UNIcell;
			new_UNIcell = UNI_cell::type_id::create("new_UNIcell");
			start_item(new_UNIcell);
			assert(new_UNIcell.randomize());
			finish_item(new_UNIcell);*/
		end
	endtask : body

endclass : seq_of_UNI

`endif


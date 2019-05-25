`ifndef SEQ__UVM
`define SEQ__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class seq_of_UNI extends uvm_sequence #(UNI_cell);
`uvm_object_utils(seq_of_UNI)
	
	UNI_cell_Sequencer UNI_seq[`RxPorts];

	int n = 100;

	function new(string name = "");
		super.new(name);
	endfunction : new


	task body();
		int count = 0;
		repeat(n) begin
			UNI_cell new_UNIcell;
			//new_UNIcell = UNI_cell::type_id::create("new_UNIcell");
			start_item(new_UNIcell);
			assert(new_UNIcell.randomize());
			finish_item(new_UNIcell);
			count++;
		end
		`uvm_info("seq_of_UNI",$sformatf(">>> %d UNI_cell foram geradas", count), UVM_LOW);
	endtask : body


endclass : seq_of_UNI

`endif


`ifndef SEQ__UVM
`define SEQ__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class seq_of_UNI extends uvm_sequence #(UNI_cell);
	`uvm_object_utils(seq_of_UNI)
	
	UNI_cell_Sequencer UNI_seq[`RxPorts];

	int n = 10;

	function new(string name = "");
		super.new(name);
	endfunction : new


	task body;
		int count = 0;

		repeat(n) begin
			UNI_cell new_UNIcell;
			new_UNIcell = UNI_cell::type_id::create("new_UNIcell");
			start_item(new_UNIcell);
			assert(new_UNIcell.randomize());
			finish_item(new_UNIcell);
			count++;
		end
		//`uvm_info("seq_of_UNI",$sformatf(">>> %0d UNI_cell foram geradas", count), UVM_HIGH);
	endtask : body
/*
	virtual task pre_body();
		if (starting_phase != null) begin
			`uvm_info(get_type_name(), $sformatf("%s pre_body() raising %s objection",get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.raise_objection(this);
		end
	endtask: pre_body

	// Drop the objection in the post_body so the objection is removed when the root sequence is complete.
	virtual task post_body();
		if (starting_phase != null) begin
			`uvm_info(get_type_name(), $sformatf("%s post_body() dropping %s objection", get_sequence_path(), starting_phase.get_name()), UVM_MEDIUM);
			starting_phase.drop_objection(this);
		end
	endtask: post_body
*/

endclass : seq_of_UNI

`endif


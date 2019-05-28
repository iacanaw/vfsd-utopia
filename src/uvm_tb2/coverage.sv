`ifndef COVERAGE__SV
`define COVERAGE__SV

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class Coverage extends uvm_subscriber #(CoverageInfo);
	`uvm_component_utils(Coverage);

	bit [1:0] src;
    bit [NumTx-1:0] fwd;

	covergroup CG_Forward;

	coverpoint src
		{bins src[] = {[0:3]};
	 	option.weight = 0;}
  	coverpoint fwd
		{bins fwd[] = {[1:15]}; // Ignore fwd==0
	 	option.weight = 0;}
  	
  	cross src, fwd;
   endgroup : CG_Forward


	function new(string name, uvm_component parent);
		super.new(name, parent);
		CG_Forward = new();
	endfunction : new

	function void write(CoverageInfo t);
		$display("@%0t: Coverage: src=%d. FWD=%b", $time, src, fwd);
		this.src = t.src;
		this.fwd = t.fwd;
		CG_Forward.sample();
	endfunction: write


endclass : Coverage

`endif
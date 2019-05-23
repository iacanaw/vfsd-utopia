`ifndef DRIVER__UVM
`define DRIVER__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class Driver extends uvm_driver#(BaseTr);
	`uvm_component_utils(Driver)

	// Utopia INPUT (Rx) interface
	virtual Utopia.TB_Rx u_if;

	// Analysis port to Scoreboard
	uvm_analysis_port #(BaseTr) drv_port;

    //------------------
    //	Constructor
    //------------------
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction: new


    //------------------
    //	Build phase
    //------------------
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Creates the communication channel to the SB
		drv_port = new("drv_port", this);

		//Connects the driver to the Utopia input interface
		if ( !(uvm_config_db #(virtual Utopia.TB_Rx)::get(this,"","u_if", u_if)) ) begin
			`uvm_fatal("driver", "Fail to build Driver");
		end
	endfunction: build_phase


    //------------------
    //	Run phase
    //------------------
	task run_phase(uvm_phase phase);
		UNI_cell c;
	    forever begin
	    	@uif.cbr;
	    	uif.cbr.data 	<= 0;
	    	uif.cbr.soc 	<= 0;
	    	uif.cbr.clav 	<= 0;
	    	// Gets a new UNI Cell from the sequencer
	    	seq_item_port.get_next_item(c);

	    	// Send the UNI Cell to the Utopia
			send(c);

			// Inform to the sequencer that the cell was sent
			seq_item_port.item_done();
		end
	endtask: run_phase

    //------------------
    //	Send task - ##Legacy code from the SV tb
    //------------------
	task send(input UNI_cell c);
		ATMCellType Pkt;

		c.pack(Pkt);
		$write("Sending cell: "); foreach (Pkt.Mem[i]) $write("%x ", Pkt.Mem[i]); $display;

		// Iterate through bytes of cell, deasserting Start Of Cell indicater
		@(Rx.cbr);
		Rx.cbr.clav <= 1;
		for (int i=0; i<=52; i++) 
			begin
			// If not enabled, loop
			while (Rx.cbr.en === 1'b1) @(Rx.cbr);

				// Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
				Rx.cbr.soc  <= (i == 0);
				Rx.cbr.data <= Pkt.Mem[i];
				@(Rx.cbr);
			end
		Rx.cbr.soc <= 'z;
		Rx.cbr.data <= 8'bx;
		Rx.cbr.clav <= 0;
	endtask: send

endclass: Driver

`endif
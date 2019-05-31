`ifndef DRIVER__UVM
`define DRIVER__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"
`include "../src/uvm_tb2/definitions.sv"

class Driver extends uvm_driver#(UNI_cell);
	`uvm_component_utils(Driver)

	int portN;

	// Utopia INPUT (Rx) interface
	virtual Utopia.TB_Rx rx_if;

	// Analysis port to Scoreboard
	uvm_analysis_port#(UNI_cell) toScbrd;

	// Analysis port to Coverage
	uvm_analysis_port#(CoverageInfo) toCov;


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
		toScbrd = new("toScbrd", this);

		// Creates the port to send packets to the Coverage module
		toCov = new("toCov", this);

		//Gets the portN for this Driver
		if ( !(uvm_config_db #(int)::get (this, "", "portN", portN)) ) begin
			`uvm_fatal("Driver", "fail on get the portN");
		end

		//Connects the driver to the Utopia input interface
		if (!(uvm_config_db #(virtual Utopia.TB_Rx)::get(this,"","rx_if", rx_if))) begin
			`uvm_fatal("driver", "Fail to get utopia interface for driver");
		end
	endfunction: build_phase


    //------------------
    //	Run phase
    //------------------
	task run_phase(uvm_phase phase);
		UNI_cell c;
		NNI_cell c_nni;
		CellCfgType CellCfg;
		CoverageInfo covInfo;
	    forever begin
	    	// Gets a new UNI Cell from the sequencer
	    	seq_item_port.get_next_item(c);

	    	// Send the UNI Cell to the Utopia
			send(c);

			// Send informations about the transaction to the Coverage module
			c_nni = c.to_NNI();
			CellCfg = top.squat.lut.read(c_nni.VPI);
			covInfo = new();
			covInfo.src = this.portN;
			covInfo.fwd = CellCfg.FWD;
			toCov.write(covInfo);
			`uvm_info($sformatf("Driver %0d",portN), "::: sending a package to Scoreboard", UVM_HIGH);
			toScbrd.write(c);

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
		//c.display($sformatf("Driver %0d -- Sending cell: ", portN));

		// Iterate through bytes of cell, deasserting Start Of Cell indicater
		@(rx_if.cbr);
		rx_if.cbr.clav <= 1;
		for (int i=0; i<=52; i++) 
			begin
			// If not enabled, loop
			while (rx_if.cbr.en === 1'b1) @(rx_if.cbr);

				// Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
				rx_if.cbr.soc  <= (i == 0);
				rx_if.cbr.data <= Pkt.Mem[i];
				@(rx_if.cbr);
			end
		rx_if.cbr.soc <= 'z;
		rx_if.cbr.data <= 8'bx;
		rx_if.cbr.clav <= 0;
	endtask: send

endclass: Driver

`endif
`ifndef DRIVER__UVM
`define DRIVER__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class Driver extends uvm_driver#(UNI_cell);
	`uvm_component_utils(Driver)

	int portN;

	// Utopia INPUT (Rx) interface
	virtual Utopia.TB_Rx u_if;

	// Analysis port to Scoreboard
	uvm_analysis_port #(BaseTr) drv_port;

	uvm_analysis_port #(CoverageInfo) toCov;

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

		// Creates the port to send packets to the Coverage module
		toCov = new("toCov", this);

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
		NNI_cell c_nni;
		CellCfgType CellCfg;
		CoverageInfo covInfo;
	    forever begin
	    	@u_if.cbr;
	    	u_if.cbr.data 	<= 0;
	    	u_if.cbr.soc 	<= 0;
	    	u_if.cbr.clav 	<= 0;
	    	// Gets a new UNI Cell from the sequencer
	    	seq_item_port.get_next_item(c);

	    	// Send the UNI Cell to the Utopia
			send(c);

			// Send informations about the transaction to the Coverage module
			c_nni = c.to_NNI();
			CellCfg = top.squat.lut.read(c_nni.VPI);
			covInfo.src = portN;
			covInfo.fwd = CellCfg.FWD;
			toCov.write(covInfo);

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
		@(u_if.cbr);
		u_if.cbr.clav <= 1;
		for (int i=0; i<=52; i++) 
			begin
			// If not enabled, loop
			while (u_if.cbr.en === 1'b1) @(u_if.cbr);

				// Assert Start Of Cell indicater, assert enable, send byte 0 (i==0)
				u_if.cbr.soc  <= (i == 0);
				u_if.cbr.data <= Pkt.Mem[i];
				@(u_if.cbr);
			end
		u_if.cbr.soc <= 'z;
		u_if.cbr.data <= 8'bx;
		u_if.cbr.clav <= 0;
	endtask: send

endclass: Driver

`endif
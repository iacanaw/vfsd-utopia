`ifndef MONITOR__UVM
`define MONITOR__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/atm_cell.sv"

class Monitor extends uvm_monitor;
	`uvm_component_utils(Monitor)

	// Utopia OUTPUT interface
	virtual Utopia tx_if;

	// Analysis port to Scoreboard
	uvm_analysis_port#(NNI_cell) toScbrd;

	// A NNI transaction to store the incomming packet from Utopia output
	NNI_cell nni_trans_collected;

	//Informs witch port this monitor is watching
	int portN;

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
		toScbrd = new("mom_port", this);

		//Gets the portN for this Monitor
		if ( !(uvm_config_db #(int)::get (this, "", "portN", portN)) ) begin
			`uvm_fatal("Monitor", "fail on get the portN");
		end

		//Connects the monitor to the Utopia output interface
		if ( !(uvm_config_db #(virtual Utopia)::get (this, "", "tx_if", tx_if)) ) begin
			`uvm_fatal("Monitor", "Fail to build Monitor");
		end

	endfunction: build_phase


	//------------------
    //	Connect phase
    //------------------
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		/*//Connects the Analysis Port to the Scoreboard
		if(!(uvm_config_db #(uvm_analysis_port #(NNI_cell) )::get(null, "uvm_test_top.env.scbrd", $sformatf("fromMon_%0d",portN), out_mon_ap))) begin
			`uvm_fatal($sformatf("fromMon_%0d",portN), "fail to get the scoreboard analysis port");
		end
		mon_port.connect(out_mon_ap);*/
	endfunction: connect_phase



	//------------------
    //	Run phase
    //------------------
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		forever begin
			ATMCellType Pkt;
			
			tx_if.cbt.clav <= 1;
			while (tx_if.cbt.soc !== 1'b1 && tx_if.cbt.en !== 1'b0)
				@(tx_if.cbt);
			for (int i=0; i<=52; i++) begin
				// If not enabled, loop
				while (tx_if.cbt.en !== 1'b0) @(tx_if.cbt);
			  
				Pkt.Mem[i] = tx_if.cbt.data;
			  	@(tx_if.cbt);
			end
			tx_if.cbt.clav <= 0;

				// Create a new transaction
				nni_trans_collected = new();
				nni_trans_collected.unpack(Pkt);

				//Send the received transaction to the scoreboard
				toScbrd.write(nni_trans_collected);

				//Debug print
				//nni_trans_collected.display($sformatf("monitor %0d nni_cell: ",portN));
			//end
		end
	endtask: run_phase

endclass: Monitor

`endif
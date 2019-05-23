`ifndef MONITOR__UVM
`define MONITOR__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class Monitor extends uvm_monitor;
	`uvm_component_utils(Monitor)

	// Utopia OUTPUT (Tx) interface
	virtual Utopia.TB_Tx u_if;

	// Analysis port to Scoreboard
	uvm_analysis_port #(BaseTr) mon_port;

	// A NNI transaction to store the incomming packet from Utopia output
	NNI_cell nni_trans_collected;

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
		mon_port = new("mom_port", this);

		//Connects the monitor to the Utopia output interface
		if ( !(uvm_config_db #(virtual Utopia.TB_Rx)::get (this,"", "u_if", u_if)) ) begin
			`uvm_fatal("Monitor", "Fail to build Monitor");
		end

	endfunction: build_phase


	//------------------
    //	Connect phase
    //------------------
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		//Connects the Analysis Port to the Scoreboard
		uvm_config_db #(uvm_analysis_port #(BaseTr) )::get(null, "test.env.scoreboard", $sformatf("mon_port_%0d",portn), mon_port);
	endfunction: connect_phase



	//------------------
    //	Run phase
    //------------------
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		
		forever
		begin :forever_loop_passive
			ATMCellType Pkt;
			@(posedge u_if.clk_in, posedge u_if.reset) // APAGAR
			//##Legacy code from the SV tb
			u_if.cbt.clav <= 1;
			while (u_if.cbt.soc !== 1'b1 && u_if.cbt.en !== 1'b0)
				@(u_if.cbt);
			for (int i=0; i<=52; i++) begin
				// If not enabled, loop
				while (u_if.cbt.en !== 1'b0)
				begin
					if (u_if.reset===1'b1) break;
					@(u_if.cbt);
				end
				if (u_if.reset===1'b1) break;

				Pkt.Mem[i] = u_if.cbt.data;
				@(u_if.cbt);
			end
			if (u_if.reset===1'b1) continue;

			u_if.cbt.clav <= 0;

			// Create a new transaction
			nni_trans_collected = new();
			nni_trans_collected.unpack(Pkt);

			//Send the transaction to the scoreboard
			mon_port.write(nni_trans_collected);

			//Debug print
			nni_trans_collected.display($sformatf("monitor %d nni_cell: ",portn));
		end: forever_loop_passive
	endtask: run_phase

endclass: Monitor

`endif
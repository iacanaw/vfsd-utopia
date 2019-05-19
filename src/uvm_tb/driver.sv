/**********************************************************************
 * Utopia UVM Monitor
 * 
 * 
 **********************************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/atm_cell.sv"

typedef virtual Utopia.TB_Rx vUtopiaRx;

typedef class Driver;

class Driver_cbs;
		virtual task pre_tx(input Driver drv,
			       input UNI_cell c,
			       inout bit drop);
		endtask : pre_tx

		virtual task post_tx(input Driver drv,
			       input UNI_cell c);
		endtask : post_tx
	endclass : Driver_cbs

class Driver extends uvm_driver #(BaseTr);
	`uvm_component_utils(Driver)

	uvm_analysis_port #(BaseTr) aport;

	virtual utopia_if uif;

	mailbox gen2drv;	// For cells sent from generator
    event   drv2gen;	// Tell generator when I am done with cell
    vUtopiaRx Rx;		// Virtual interface for transmitting cells
    Driver_cbs cbsq[$]; // Queue of callback objects
    int PortID;


	function new(string name="", uvm_component parent, input mailbox gen2drv, input event drv2gen, input vUtopiaRx Rx, input int PortID);
		super.new(name, parent);

		this.gen2drv = gen2drv;
   		this.drv2gen = drv2gen;
   		this.Rx      = Rx;
   		this.PortID  = PortID;

	endfunction: new

	function void build_phase(uvm_phase phase);
		aport = new("aport", this);
		super.build_phase(phase);
		void'(uvm_resource_db#(virtual utopia_if)::read_by_name(.scope("ifs"), .name("utopia_if"), .val(uif)));
	endfunction: build_phase

	task run_phase(uvm_phase phase);
		
		UNI_cell c;
		bit drop = 0;

	    // Initialize ports
	    Rx.cbr.data  <= 0;
	    Rx.cbr.soc   <= 0;
	    Rx.cbr.clav  <= 0;

	    forever begin
        // Read the cell at the front of the mailbox
			gen2drv.peek(c);
		    begin: Tx
			 // Pre-transmit callbacks
			foreach (cbsq[i]) begin
				cbsq[i].pre_tx(this, c, drop);
			    if (drop) disable Tx; 	// Don't transmit this cell
			end

			c.display($sformatf("@%0t: Drv%0d: ", $time, PortID));
			send(c);
			
			// Post-transmit callbacks
			foreach (cbsq[i])
				cbsq[i].post_tx(this, c);
		    end

		    gen2drv.get(c);     // Remove cell from the mailbox
		    ->drv2gen;	  // Tell the generator we are done with this cell

		end

	endtask: run_phase

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
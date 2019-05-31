`ifndef AGENT__UVM
`define AGENT__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"
`include "../src/uvm_tb2/driver.sv"
`include "../src/uvm_tb2/monitor.sv"

class Agent extends uvm_agent;
	`uvm_component_utils(Agent)

	Driver    drv;
	UNI_cell_Sequencer seq;
	Monitor   mon;

    // the Port ID in which this agent is connected
    int portN;


    //------------------
    //	Constructor
    //------------------
	function new(string name="", uvm_component parent);
		super.new(name, parent);
	endfunction : new


	//------------------
    //	Build phase
    //------------------
    function void build_phase(uvm_phase phase);
        // the Utopia interface that comes from TOP instantiation
        virtual Utopia tx_if, rx_if;
        
    	super.build_phase(phase);

        if ( !(uvm_config_db #(int)::get(this, "", "portN", portN)) ) begin
            `uvm_fatal("Agent", "fails on get the portN");
        end

    	if(!(uvm_config_db#(virtual Utopia)::get(this, "", "tx_if", tx_if))) begin
            `uvm_fatal("agent", "fail to get the Utopia interface");
        end

        if(!(uvm_config_db#(virtual Utopia)::get(this, "", "rx_if", rx_if))) begin
            `uvm_fatal("agent", "fail to get the Utopia interface");
        end

    	// Sets the driver to the Utopia.TB_Rx interface
        uvm_config_db #(int)::set(this,$sformatf("drv_%0d",portN), "portN", portN);
    	uvm_config_db #(virtual Utopia.TB_Rx)::set(this,$sformatf("drv_%0d",portN), "rx_if", rx_if);
        // Creates the Driver
        drv = Driver::type_id::create($sformatf("drv_%0d",portN), this);

    	// Creates the Sequencer
    	seq = UNI_cell_Sequencer::type_id::create("seq", this);

    	// Sets the monitor to the Utopia.TB_Tx interface
        uvm_config_db #(int)::set(this,$sformatf("mon_%0d",portN), "portN", portN);
    	uvm_config_db #(virtual Utopia)::set (this,$sformatf("mon_%0d",portN), "tx_if", tx_if);
        // Creates the Monitor
        mon = Monitor::type_id::create($sformatf("mon_%0d",portN), this);

    endfunction : build_phase


	//------------------
    //	Connect phase
    //------------------
    function void connect_phase(uvm_phase phase);
    	super.connect_phase(phase);

  		drv.seq_item_port.connect(seq.seq_item_export);

        //mon.seq_item_port.connect(seq.seq_item_export);

    endfunction: connect_phase

    function void end_of_elaboration();

        drv.seq_item_port.debug_connected_to();
        //mon.item_collected_port.debug_connected_to();

    endfunction : end_of_elaboration


endclass : Agent

`endif
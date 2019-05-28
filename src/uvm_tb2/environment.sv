`ifndef ENVIRONMENT__UVM
`define ENVIRONMENT__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/config.sv"
`include "../src/uvm_tb2/agent.sv"
`include "../src/uvm_tb2/scoreboard.sv"
`include "../src/uvm_tb2/coverage.sv"

//Imported from the SV original projetc
`include "../src/uvm_tb2/cpu_ifc.sv"
`include "../src/uvm_tb2/cpu_driver.sv"

class Environment extends uvm_env;
	`uvm_component_utils(Environment)

	Agent ag[`RxPorts];
	Scoreboard scbrd;
	Coverage cov;


    //------------------
    //	Constructor
    //------------------
	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


	//------------------
    //	Build phase
    //------------------
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);

    	// Creates the Scoreboard module
    	scbrd = Scoreboard::type_id::create("scbrd", this);

    	// Creates the Coverage module
    	cov = Coverage::type_id::create("cov", this);

    	foreach(ag[i]) begin
    		// Creates the Agent[i]
    		ag[i] = Agent::type_id::create($sformatf("ag_%0d",i), this);
            // Sets the port in which each agent will be connected 
            uvm_config_db#(int)::set(this,$sformatf("ag_%0d",i), "portN", i);
    	end
    endfunction: build_phase


    //------------------
    //	Configure phase
    //------------------
    task configure_phase(uvm_phase phase);
		super.configure_phase(phase);
	endtask : configure_phase


	//------------------
    //	Configure phase
    //------------------
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		// Connects Scoreboard with Coverage module
 		//scbrd.toCov_port.connect(cov.analysis_export);
	endfunction: connect_phase

endclass : Environment


`endif
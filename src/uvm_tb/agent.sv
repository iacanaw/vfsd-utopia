import uvm_pkg::*;
`include "uvm_macros.svh"

typedef uvm_sequencer#(BaseTr) utopia_sequencer;

class Agent extends uvm_agent;
	`uvm_component_utils(Agent)

	uvm_analysis_port#(BaseTr) aport;

	//NNI_generator nni_gen;
	utopia_sequencer uni_seq; 
	Driver drv;
	Monitor mon;

	function new(string name, uvm_component parent);
    	super.new(name, parent);
  	endfunction: new

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		aport = new(.name("aport"), .parent(this));
		uni_seq = utopia_sequencer::type_id::create(.name("uni_seq"), .parent(this));
		drv = Driver::type_id::create(.name("driver"), .parent(this));
		mon = Monitor::type_id::create(.name("monitor"), .parent(this));
	endfunction: build_phase

	function void connect_phase(uvm_phase connect);
		super.connect_phase(phase);
		drv.seq_item_port.connect(uni_seq.seq_item_port);
		mon.aport.connect(aport);
	endfunction : connect_phase

endclass: Agent
`ifndef TEST__UVM
`define TEST__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../src/uvm_tb2/environment.sv"
`include "../src/uvm_tb2/seq_of_UNI.sv"
`include "../src/uvm_tb2/cpu_driver.sv"
`include "../src/uvm_tb2/config.sv"
`include "../src/uvm_tb2/cpu_ifc.sv"

class test extends uvm_test;
  `uvm_component_utils(test);

  Environment env;
  seq_of_UNI seq;

  CPU_driver cpu;
  Config cfg;
  virtual cpu_ifc mif;

  function new(string name="test", uvm_component parent);
    super.new(name, parent);
  endfunction: new

  task configure_phase(uvm_phase phase);
    super.configure_phase(phase);
  endtask : configure_phase

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Creates the environment
    env = Environment::type_id::create("env", this);

    // Creates the sequencer
    seq = seq_of_UNI::type_id::create("seq", this);


    cfg = new(`RxPorts,`TxPorts);
    uvm_config_db#(virtual cpu_ifc)::get(null, "*", "mif", mif);
    cpu = new(mif, cfg);
  endfunction : build_phase

  //---------------------------------------
  // end_of_elabaration phase
  //---------------------------------------
  function void end_of_elaboration();
  //print's the topology
    uvm_top.print_topology();
    //uvm_factory::get().print();
  endfunction : end_of_elaboration


  task run_phase(uvm_phase phase);
    //int indice=0;
    phase.raise_objection(this);
    cpu.run();
    // start the virtual sequence
    foreach (seq.UNI_seq[i]) begin
      seq.UNI_seq[i] = env.ag[i].seq;
    end

    foreach (seq.UNI_seq[i]) begin
      fork
        seq.start(seq.UNI_seq[i]);
      join
    end
    phase.drop_objection(this);
    
  endtask : run_phase

endclass : test

`endif 


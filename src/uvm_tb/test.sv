`ifndef TEST__UVM
`define TEST__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../src/uvm_tb/environment.sv"
`include "../src/uvm_tb/seq_of_UNI.sv"
`include "../src/uvm_tb/cpu_driver.sv"
`include "../src/uvm_tb/config.sv"
`include "../src/uvm_tb/cpu_ifc.sv"

class test extends uvm_test;
  `uvm_component_utils(test);

  Environment env;
  seq_of_UNI seq;
  CPU_driver cpu;
  Config cfg;
  vCPU_T _mif;

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

    // 
    cfg = new(`RxPorts,`TxPorts);
    if (!(uvm_config_db#(vCPU_T)::get(null, "*", "mif", _mif))) begin
      `uvm_fatal("driver", "fail to build cpu_ifc");
    end
    cpu = new(_mif, cfg);

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
      seq.start(seq.UNI_seq[i]);
    end

    /*foreach(seq.UNI_seq[i]) begin
      fork 
        begin: parallel
          `uvm_info("--------------------------->Sequencer",$sformatf("%0d - starting",i), UVM_HIGH);
          seq.start(seq.UNI_seq[i]);
        end: parallel
      wait fork;
      join
    end*/
    phase.drop_objection(this);
    
  endtask : run_phase

endclass : test

`endif 


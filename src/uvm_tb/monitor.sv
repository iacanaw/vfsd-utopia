/**********************************************************************
 * Utopia UVM Monitor
 * 
 * 
 **********************************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/atm_cell.sv"

typedef virtual Utopia.TB_Tx vUtopiaTx;

typedef class Monitor;

class Monitor_cbs;
      virtual task post_rx(input Monitor mon, input NNI_cell c);
      endtask : post_rx
endclass : Monitor_cbs

class Monitor extends uvm_monitor;

   `uvm_component_utils(Monitor)

   uvm_analysis_port #(BaseTr) aport;

   //`uvm_analysis_port#(transation_utopia) monitor_port;

   virtual utopia_if uif;

   vUtopiaTx Tx;        // Virtual interface with output of DUT
   Monitor_cbs cbsq[$]; // Queue of callback objects
   int PortID;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern function void initialize(input vUtopiaTx Tx, input int PortID);
   extern task run_phase(uvm_phase phase);
   extern task receive(output NNI_cell c);
endclass : Monitor     

//---------------------------------------------------------------------------
// new(): construct an object
//---------------------------------------------------------------------------
function Monitor::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction: new


//---------------------------------------------------------------------------
// build_phase(): 
//---------------------------------------------------------------------------
function void Monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
      //From old SV.Monitor
   
   void'(uvm_resource_db#(virtual utopia_if )::read_by_name (.scope("ifs"), .name(" utopia_if "), .val(uif)));
   //monitor_port = new(.name(" monitor_port "), .parent(this));
endfunction: build_phase

//---------------------------------------------------------------------------
// initialize(): 
//---------------------------------------------------------------------------
function void Monitor::initialize(input vUtopiaTx Tx, input int PortID);
   this.Tx     = Tx;
   this.PortID = PortID;
endfunction: initialize

//---------------------------------------------------------------------------
// run(): Run the monitor
//---------------------------------------------------------------------------
task Monitor::run_phase(uvm_phase phase);
   NNI_cell c;
   aport = new("aport", this); 
   
   forever begin
      receive(c);
      foreach (cbsq[i])
      cbsq[i].post_rx(this, c);   // Post-receive callback
   end
endtask: run_phase


//---------------------------------------------------------------------------
// receive(): Read a cell from the DUT output, pack it into a NNI cell
//---------------------------------------------------------------------------
task Monitor::receive(output NNI_cell c);
   ATMCellType Pkt;

   Tx.cbt.clav <= 1;
   while (Tx.cbt.soc !== 1'b1 && Tx.cbt.en !== 1'b0)
     @(Tx.cbt);
   for (int i=0; i<=52; i++) begin
      // If not enabled, loop
      while (Tx.cbt.en !== 1'b0) @(Tx.cbt);
      
      Pkt.Mem[i] = Tx.cbt.data;
      @(Tx.cbt);
   end

   Tx.cbt.clav <= 0;

   c = new();
   c.unpack(Pkt);
   c.display($sformatf("@%0t: Mon%0d: ", $time, PortID));

endtask : receive
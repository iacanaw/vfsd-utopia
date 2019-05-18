/**********************************************************************
 * Utopia UVM Monitor
 * 
 * 
 **********************************************************************/

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "atm_cell.sv"

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

   extern function new(string name, uvm_component parent, input vUtopiaTx Tx, input int PortID);
   extern function void build_phase(uvm_phase phase);
   extern task run_phase(uvm_phase phase);
   extern task receive(output NNI_cell c);
endclass : Monitor     

//---------------------------------------------------------------------------
// new(): construct an object
//---------------------------------------------------------------------------
function Monitor::new(string name, uvm_component parent, input vUtopiaTx Tx, input int PortID);
   super.new(name, parent);

   //From old SV.Monitor
   this.Tx     = Tx;
   this.PortID = PortID;

endfunction: new


//---------------------------------------------------------------------------
// build_phase(): 
//---------------------------------------------------------------------------
function void Monitor::build_phase(uvm_phase phase);
   super.build_phase(phase);
   void'(uvm_resource_db#(virtual utopia_if )::read_by_name (.scope("ifs"), .name(" utopia_if "), .val(uif)));
   //monitor_port = new(.name(" monitor_port "), .parent(this));
endfunction: build_phase


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
import uvm_pkg::*;
/*********************************************************************/
`timescale 1ns/1ns

`include "uvm_macros.svh"
`include "../src/dut/squat.sv"
`include "../src/uvm_tb/test.sv"
`include "../src/uvm_tb/cpu_ifc.sv"
`include "../src/uvm_tb/utopia.sv"


//`define SYNTHESIS	// conditional compilation flag for synthesis
//`define FWDALL		// conditional compilation flag to forward cells

`define TxPorts 4  // set number of transmit ports
`define RxPorts 4  // set number of receive ports


module top;

  parameter int NumRx = `RxPorts;
  parameter int NumTx = `TxPorts;

  logic rst, clk;

  // System Clock and Reset
  initial begin
    rst = 0; clk = 0;
    #5ns rst = 1;
    #5ns clk = 1;
    #5ns rst = 0; clk = 0;
    forever 
      #5ns clk = ~clk;
  end

  Utopia Rx[0:NumRx-1] ();	// NumRx x Level 1 Utopia Rx Interface
  Utopia Tx[0:NumTx-1] ();	// NumTx x Level 1 Utopia Tx Interface
  cpu_ifc mif();	  // Intel-style Utopia parallel management interface
  squat #(NumRx, NumTx) squat(Rx, Tx, mif, rst, clk);	// DUT

  initial 
    uvm_config_db#(vCPU_T)::set(null, "*", "mif", mif);

  // pass the interfaces to the agents and they will pass it to their monitors and drivers
  for(genvar i=0; i< NumRx; i++) begin 
    initial uvm_config_db#(virtual Utopia)::set(null, $sformatf("uvm_test_top.env.ag_%0d",i), "rx_if", Rx[i]);
    initial uvm_config_db#(virtual Utopia)::set(null, $sformatf("uvm_test_top.env.ag_%0d",i), "tx_if", Tx[i]);
  end

  /*initial
  begin
    $dumpfile("dump.vcd"); $dumpvars;
  end */

  initial begin
    run_test();
    $write("TEST DONE! YOU GOT IT!");
  end

endmodule : top

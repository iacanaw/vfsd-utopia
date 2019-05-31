`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV


import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb2/atm_cell.sv"

class Scoreboard extends uvm_scoreboard;
	`uvm_component_utils(Scoreboard)

	// UNI Cells comming from Drivers - every driver writes in this port
	uvm_analysis_port#(UNI_cell) fromDrv;
	uvm_tlm_analysis_fifo#(UNI_cell) incomming_UNIcell_FIFO;

	// NNI Cells comming from Monitors - each monitor has a separeted channel 
	uvm_analysis_port#(NNI_cell) fromMon[`TxPorts];
	uvm_tlm_analysis_fifo#(NNI_cell) incomming_NNIcell_FIFO[`TxPorts];

	// iexpect increases as UNI packages is generated
	// ifound increases as NNI packages  
	// iactual increases as NNI packages is captured and was registered into expect_cells.q[]
	// iactual increases as NNI packages is captured and was NOT registered into expect_cells.q[]
	int iexpect, ifound, nErrors;
 	NNI_cell error_cells[$];

 	// Queue where the input UNIcells are temporally stored until they leave at some output port and be checked by the sb
 	UNI_cell UNICell_FIFO[`RxPorts][$];



    //------------------
    //	Constructor
    //------------------
 	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new


    //------------------
    //	Build phase
    //------------------
	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		// Start the number of errors
		nErrors=0;
		iexpect=0;
		ifound=0;

		// Creates the port used to receive UNIcells from drivers
		fromDrv = new("fromDrv", this);
		uvm_config_db#(uvm_analysis_port#(UNI_cell))::set(this, "", "fromDrv", fromDrv);

		// Creates the FIFO used to store each UNIcells recieved from drivers
		incomming_UNIcell_FIFO  = new("incomming_UNIcell_FIFO", this); 

		foreach (fromMon[i])
		begin
			// Creates each port used to receive NNIcells from monitors
			fromMon[i] = new($sformatf("fromMon_%0d",i), this); 
			uvm_config_db#(uvm_analysis_port#(NNI_cell))::set(this, "", $sformatf("fromMon_%0d",i), fromMon[i]);

			// Creates each FIFO used to store NNIcells recieved from monitors
			incomming_NNIcell_FIFO[i] = new( $sformatf("incomming_NNIcell_FIFO_%0d",i), this);
		end



	endfunction : build_phase


    //------------------
    //	Build phase
    //------------------
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);

		//Connects the input UNI_Cells port to the FIFO
		fromDrv.connect(incomming_UNIcell_FIFO.analysis_export);

		// Connects each input NNI_Cells ports to each FIFO
		foreach (fromMon[i]) fromMon[i].connect(incomming_NNIcell_FIFO[i].analysis_export);

	endfunction: connect_phase


    //------------------
    //	Run task (main)
    //------------------
	task run_phase(uvm_phase phase);
	  	fork
			save_expected();
			foreach (incomming_NNIcell_FIFO[i]) begin
				fork
					int idx=i;
					verify(idx);
				join_none;
			end
			wait fork;
		join
	endtask: run_phase


    //------------------
    //	Store input UNI_cells
    //------------------
    task save_expected();
    	UNI_cell sample;
    	NNI_cell sample_nni;
    	CellCfgType CellCfg;

    	forever begin
    		// Reads a sample from the UNI_cell FIFO
		    //sample = UNI_cell::type_id::create("sample");
		    incomming_UNIcell_FIFO.get(sample);
		    // Converts it to NNI_cell
		    //sample_nni = NNI_cell::type_id::create("sample_nni");
		    sample_nni = sample.to_NNI();
		    // gets the CellCfgType
			//CellCfg = CellCfgType::type_id::create("CellCfg");
		    CellCfg = top.squat.lut.read(sample_nni.VPI);

	   		for (int i=0; i<`TxPorts; i++) begin
	   			if(CellCfg.FWD[i]) begin
	   				//phase.raise_objection(this);
   				 	UNICell_FIFO[i].push_back(sample);
	 		   		iexpect++;
	   				`uvm_info("-------> Scoreboard", $sformatf("INPUT PACKET RECEIVED !!!! id: %0d",iexpect), UVM_HIGH);
	   			end
	   		end
   		end
   	endtask


    //------------------
    //	Check for every NNI_cell in the correspondent input UNI_cell fifo
    //------------------
   	task verify(int idx);
   		NNI_cell toCheck;
   		NNI_cell aux;
   		bit found;
   		forever begin
   			// Reads a NNI cell from NNI_cells FIFO 
   			//toCheck = NNI_cell::type_id::create("check");
   			incomming_NNIcell_FIFO[idx].get(toCheck);
   			`uvm_info("Scoreboard", "OUTPUT PACKET RECEIVED !!!!", UVM_HIGH);

   			// Verify if the expected source queue is empty
   			if (UNICell_FIFO[idx].size() == 0) begin
   				error_cells.push_back(toCheck);
				nErrors++;
				return;
		    end
		    found = 0;
		    foreach (UNICell_FIFO[idx,i]) begin
		    	if(toCheck.compare(UNICell_FIFO[idx][i].to_NNI()))begin
				//if (UNICell_FIFO[idx][i].compare_NNI(toCheck)) begin
					UNICell_FIFO[idx].delete(i);
					ifound++;
					found = 1;
					return;
				end
			end
			if (found == 0) begin
				error_cells.push_back(toCheck);
				nErrors++;
				return;
			end
		end
   	endtask


    //------------------
    //	Report the Scoreboard analysis results
    //------------------
   	function void extract_phase(uvm_phase phase);
		super.extract_phase(phase);
		`uvm_info("Scoreboard extract_phase",$sformatf("@%0t: %m %0d expected cells, %0d actual cells received and checked", $time, iexpect, ifound),UVM_HIGH);
		`uvm_info("Scoreboard extract_phase",$sformatf("@%0t: %m number of errors: %d", $time, nErrors),UVM_HIGH);
	endfunction : extract_phase

endclass : Scoreboard
`endif;
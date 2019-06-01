class parallel_seq extends uvm_sequence#(uvm_sequence_item);  
	`uvm_object_utils(parallel_seq);

	// Defines a sequencer for each input port
	UNI_cell_Sequencer UNI_seq[`RxPorts];

	function new(string name="parallel_seq");
		super.new(name);	
	endfunction : new

	task pre_body();
		super.pre_body();
	endtask : pre_body

	task body();
		fork begin : isolating_thread
			for(int index=0; index<`RxPorts; index++) begin : for_loop
				fork
					automatic int idx=index; begin
					if(!seq[idx].randomize()) begin
						`uvm_error("parallel_sequencer", "invalid sequence randomization"); 
					end
					seq[idx].start(UNI_seq[idx]);
				end
				join_none;
			end : for_loop
			wait fork; // This block the current thread until all child threads have completed. 
		end : isolating_thread
		join
	endtask : body

endclass : parallel_seq;
`ifndef ATM_CELL__UVM
`define ATM_CELL__UVM

import uvm_pkg::*;
`include "uvm_macros.svh"

`include "../src/uvm_tb/definitions.sv"

class CoverageInfo extends uvm_sequence_item;
   `uvm_object_utils(CoverageInfo)
   bit [`TxPorts-1:0] fwd;
   bit [1:0] src;

   function new(string name = "");
      super.new(name);
   endfunction: new

endclass;


/*virtual class BaseTr extends ;
`uvm_object_utils(BaseTr)

  static int count;  // Number of instance created
  int id;            // Unique transaction id

  function new(string name = "");
   super.new(name);
    id = count++;
  endfunction

endclass // BaseTr*/

typedef class NNI_cell;


/////////////////////////////////////////////////////////////////////////////
// UNI Cell Format
/////////////////////////////////////////////////////////////////////////////
class UNI_cell extends uvm_sequence_item;
   // Physical fields
   rand bit        [3:0]  GFC;
   rand bit        [7:0]  VPI;
   rand bit        [15:0] VCI;
   rand bit               CLP;
   rand bit        [2:0]  PT;
        bit        [7:0]  HEC;
   rand bit [0:47] [7:0]  Payload;

   //static int count;  // Number of instance created
   //int id;            // Unique transaction id

   // Meta-data fields
   static bit [7:0] syndrome[0:255];
   static bit syndrome_not_generated = 1;

   `uvm_object_utils_begin(UNI_cell)
         `uvm_field_int(GFC,UVM_ALL_ON)
         `uvm_field_int(VPI,UVM_ALL_ON)
         `uvm_field_int(VCI,UVM_ALL_ON)
         `uvm_field_int(CLP,UVM_ALL_ON)
         `uvm_field_int(PT,UVM_ALL_ON)
         `uvm_field_int(HEC,UVM_ALL_ON)
         `uvm_field_int(Payload,UVM_ALL_ON) 
   `uvm_object_utils_end


//-----------------------------------------------------------------------------
function new(string name = "");
   super.new(name);
   if (syndrome_not_generated)
      generate_syndrome();
   //id = count++;
endfunction : new


//-----------------------------------------------------------------------------
// Compute the HEC value after all other data has been chosen
function void post_randomize();
   HEC = hec({GFC, VPI, VCI, CLP, PT});
endfunction : post_randomize



//-----------------------------------------------------------------------------

function bit compare(input UNI_cell to);
   UNI_cell other;
   $cast(other, to);
   if (this.GFC != other.GFC)         return 0;
   if (this.VPI != other.VPI)         return 0;
   if (this.VCI != other.VCI)         return 0;
   if (this.CLP != other.CLP)         return 0;
   if (this.PT  != other.PT)          return 0;
   if (this.HEC != other.HEC)         return 0;
   if (this.Payload != other.Payload) return 0;
   return 1;
endfunction : compare


function void display(input string prefix);
   ATMCellType p;

   //$display("%sUNI id:%0d GFC=%x, VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x",
	//    prefix, id, GFC, VPI, VCI, CLP, PT, HEC, Payload[0]);
   $display("%sUNI GFC=%x, VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x",
       prefix, GFC, VPI, VCI, CLP, PT, HEC, Payload[0]);
   this.pack(p);
   $write("%s", prefix);
   foreach (p.Mem[i]) $write("%x ", p.Mem[i]); $display;
   //$write("%sUNI Payload=%x %x %x %x %x %x ...",
   //	  prefix, Payload[0], Payload[1], Payload[2], Payload[3], Payload[4], Payload[5]);
   //foreach(Payload[i]) $write(" %x", Payload[i]);
   $display;
endfunction : display


function void copy_data(input UNI_cell copy);
   copy.GFC     = this.GFC;
   copy.VPI     = this.VPI;
   copy.VCI     = this.VCI;
   copy.CLP     = this.CLP;
   copy.PT      = this.PT;
   copy.HEC     = this.HEC;
   copy.Payload = this.Payload;
endfunction : copy_data


function UNI_cell copy(input UNI_cell to);
   UNI_cell dst;
   if (to == null) dst = new();
   else            $cast(dst, to);
   copy_data(dst);
   return dst;
endfunction : copy


function void pack(output ATMCellType to);
   to.uni.GFC     = this.GFC;
   to.uni.VPI     = this.VPI;
   to.uni.VCI     = this.VCI;
   to.uni.CLP     = this.CLP;
   to.uni.PT      = this.PT;
   to.uni.HEC     = this.HEC;
   to.uni.Payload = this.Payload;
   //$write("Packed: "); foreach (to.Mem[i]) $write("%x ", to.Mem[i]); $display;
endfunction : pack


function void unpack(input ATMCellType from);
   this.GFC     = from.uni.GFC;
   this.VPI     = from.uni.VPI;
   this.VCI     = from.uni.VCI;
   this.CLP     = from.uni.CLP;
   this.PT      = from.uni.PT;
   this.HEC     = from.uni.HEC;
   this.Payload = from.uni.Payload;
endfunction : unpack


//---------------------------------------------------------------------------
// Generate a NNI cell from an UNI cell - used in scoreboard
function NNI_cell to_NNI();
   NNI_cell copy;
   copy = new();
   copy.VPI     = this.VPI;   // NNI has wider VPI
   copy.VCI     = this.VCI;
   copy.CLP     = this.CLP;
   copy.PT      = this.PT;
   copy.HEC     = this.HEC;
   copy.Payload = this.Payload;
   return copy;
endfunction : to_NNI


//---------------------------------------------------------------------------
// Generate the syndome array, used to compute HEC
function void generate_syndrome();
   bit [7:0] sndrm;
   for (int i = 0; i < 256; i = i + 1 ) begin
      sndrm = i;
      repeat (8) begin
         if (sndrm[7] === 1'b1)
           sndrm = (sndrm << 1) ^ 8'h07;
         else
           sndrm = sndrm << 1;
      end
      syndrome[i] = sndrm;
   end
   syndrome_not_generated = 0;
endfunction : generate_syndrome

//---------------------------------------------------------------------------
// Function to compute the HEC value
function bit [7:0] hec (bit [31:0] hdr);
   hec = 8'h00;
   repeat (4) begin
      hec = syndrome[hec ^ hdr[31:24]];
      hdr = hdr << 8;
   end
   hec = hec ^ 8'h55;
endfunction : hec

endclass : UNI_cell



/////////////////////////////////////////////////////////////////////////////
// UNI Cell Sequencer
/////////////////////////////////////////////////////////////////////////////
//typedef uvm_sequencer #(UNI_cell) UNI_cell_Sequencer;




/////////////////////////////////////////////////////////////////////////////
// NNI Cell Format
/////////////////////////////////////////////////////////////////////////////
class NNI_cell extends uvm_sequence_item;
   // Physical fields
   rand bit        [11:0] VPI;
   rand bit        [15:0] VCI;
   rand bit               CLP;
   rand bit        [2:0]  PT;
   bit        [7:0]  HEC;
   rand bit [0:47] [7:0]  Payload;

   static int count;  // Number of instance created
   int id;            // Unique transaction id

   // Meta-data fields
   static bit [7:0] syndrome[0:255];
   static bit syndrome_not_generated = 1;


   function new(string name = "");
      super.new(name);
      if (syndrome_not_generated)
        generate_syndrome();
      id = count++;
   endfunction : new


   //-----------------------------------------------------------------------------
   // Compute the HEC value after all other data has been chosen
   function void post_randomize();
      HEC = hec({VPI, VCI, CLP, PT});
   endfunction : post_randomize


   function bit compare(input NNI_cell to);
      NNI_cell other;
      $cast(other, to);
      if (this.VPI != other.VPI)         return 0;
      if (this.VCI != other.VCI)         return 0;
      if (this.CLP != other.CLP)         return 0;
      if (this.PT  != other.PT)          return 0;
      if (this.HEC != other.HEC)         return 0;
      if (this.Payload != other.Payload) return 0;
      return 1;
   endfunction : compare


   function void display(input string prefix);
      ATMCellType p;

      $display("%sNNI id:%0d VPI=%x, VCI=%x, CLP=%b, PT=%x, HEC=%x, Payload[0]=%x",
   	    prefix, id, VPI, VCI, CLP, PT, HEC, Payload[0]);
      this.pack(p);
      $write("%s", prefix);
      foreach (p.Mem[i]) $write("%x ", p.Mem[i]); $display;
      //$write("%sUNI Payload=%x %x %x %x %x %x ...",
      $display;
   endfunction : display

   function void copy_data(input NNI_cell copy);
      copy.VPI     = this.VPI;
      copy.VCI     = this.VCI;
      copy.CLP     = this.CLP;
      copy.PT      = this.PT;
      copy.HEC     = this.HEC;
      copy.Payload = this.Payload;
   endfunction : copy_data

   function NNI_cell copy(input NNI_cell to);
      NNI_cell dst;
      if (to == null) dst = new();
      else            $cast(dst, to);
      copy_data(dst);
      return dst;
   endfunction : copy

   function void pack(output ATMCellType to);
      to.nni.VPI     = this.VPI;
      to.nni.VCI     = this.VCI;
      to.nni.CLP     = this.CLP;
      to.nni.PT      = this.PT;
      to.nni.HEC     = this.HEC;
      to.nni.Payload = this.Payload;
   endfunction : pack

   function void unpack(input ATMCellType from);
      this.VPI     = from.nni.VPI;
      this.VCI     = from.nni.VCI;
      this.CLP     = from.nni.CLP;
      this.PT      = from.nni.PT;
      this.HEC     = from.nni.HEC;
      this.Payload = from.nni.Payload;
   endfunction : unpack

   //---------------------------------------------------------------------------
   // Generate the syndome array, used to compute HEC
   function void generate_syndrome();
      bit [7:0] sndrm;
      for (int i = 0; i < 256; i = i + 1 ) begin
         sndrm = i;
         repeat (8) begin
            if (sndrm[7] === 1'b1)
              sndrm = (sndrm << 1) ^ 8'h07;
            else
              sndrm = sndrm << 1;
         end
         syndrome[i] = sndrm;
      end
      syndrome_not_generated = 0;
   endfunction : generate_syndrome

   //---------------------------------------------------------------------------
   // Function to compute the HEC value
   function bit [7:0] hec (bit [31:0] hdr);
      hec = 8'h00;
      repeat (4) begin
         hec = syndrome[hec ^ hdr[31:24]];
         hdr = hdr << 8;
      end
      hec = hec ^ 8'h55;
   endfunction : hec

endclass : NNI_cell  




`endif // ATM_CELL__SV

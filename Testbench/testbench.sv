/********************************************************************************************
Top Module for Dual Port RAM Testbench
********************************************************************************************/
`include "ram_pkg.sv"
`include "ram_if.sv"
module top();

   // Import package (contains all TB components)
   import ram_pkg::*;   
    
   parameter cycle = 10;
  
   reg clock;

   // ================= INTERFACE INSTANCE =================
   ram_if DUV_IF(clock);

   // ================= TEST HANDLES =================
   ram_base_test   base_test_h;
   ram_test_extnd1 ext_test_h1;
   ram_test_extnd2 ext_test_h2;

   // ================= DUT INSTANTIATION =================
   ram_4096 RAM (
      .clk        (clock),
      .data_in    (DUV_IF.data_in),
      .data_out   (DUV_IF.data_out),
      .wr_address (DUV_IF.wr_address),
      .rd_address (DUV_IF.rd_address),
      .read       (DUV_IF.read),
      .write      (DUV_IF.write)
   ); 

   // ================= CLOCK GENERATION =================
   initial begin
      clock = 1'b0;
      forever #(cycle/2) clock = ~clock;
   end
   
   // ================= TEST SELECTION =================
   initial begin
	 
      `ifdef VCS
         $fsdbDumpvars(0, top);   // Waveform dump
      `endif

      // -------- TEST 1: BASE TEST --------
      if($test$plusargs("TEST1")) begin
         base_test_h = new(DUV_IF, DUV_IF, DUV_IF, DUV_IF);
         number_of_transactions = 100;
         base_test_h.build();
         base_test_h.run();
         $finish;
      end

      // -------- TEST 2: EXTENDED TEST 1 --------
      if($test$plusargs("TEST2")) begin
         ext_test_h1 = new(DUV_IF, DUV_IF, DUV_IF, DUV_IF);
         number_of_transactions = 500;
         ext_test_h1.build();
         ext_test_h1.run(); 
         $finish;
      end

      // -------- TEST 3: EXTENDED TEST 2 --------
      if($test$plusargs("TEST3")) begin
         ext_test_h2 = new(DUV_IF, DUV_IF, DUV_IF, DUV_IF);
         number_of_transactions = 500;
         ext_test_h2.build();
         ext_test_h2.run();
         $finish;
      end

   end

endmodule

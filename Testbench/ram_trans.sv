// Transaction Class

class ram_trans;

   // Randomized fields
   // 64-bit data
   rand bit [63:0] data;

   // 12-bit read and write addresses
   rand bit [11:0] rd_address;
   rand bit [11:0] wr_address;

   // Control signals (1-bit each)
   rand bit read;
   rand bit write;

   // Output data (captured during read)
   logic [63:0] data_out;

   // Static counters for tracking transactions
   static int trans_id;
   static int no_of_read_trans;
   static int no_of_write_trans;
   static int no_of_RW_trans;

   // Constraints

   // Read and write addresses should not be equal
   constraint VALID_ADDR {
      wr_address != rd_address;
   }

   // At least one operation (read/write) must be active
   constraint VALID_CTRL {
      {read, write} != 2'b00;
   }

   // Data range constraint
   constraint VALID_DATA {
      data inside {[1:4294]};
   }

   // Post-randomization function
   // Updates counters and displays transaction details
   function void post_randomize();

      // Increment total transaction count
      trans_id++;

      // Count read-only transactions
      if (this.read == 1 && this.write == 0)
         no_of_read_trans++;

      // Count write-only transactions
      if (this.write == 1 && this.read == 0)
         no_of_write_trans++;

      // Count read-write transactions
      if (this.read == 1 && this.write == 1)
         no_of_RW_trans++;

      // Display randomized data
      this.display("\tRANDOMIZED DATA");

   endfunction: post_randomize


   // Display function
   // Prints all transaction details
   virtual function void display(input string message);

      $display("=============================================================");
      $display("%s", message);

      if (message == "\tRANDOMIZED DATA") begin
         $display("\t_______________________________");
         $display("\tTransaction No. %d", trans_id);
         $display("\tRead Transaction No. %d", no_of_read_trans);
         $display("\tWrite Transaction No. %d", no_of_write_trans);
         $display("\tRead-Write Transaction No. %d", no_of_RW_trans);
         $display("\t_______________________________");
      end

      $display("\tRead=%d, write=%d", read, write);
      $display("\tRead_Address=%d, Write_Address=%d", rd_address, wr_address);
      $display("\tData=%d", data);
      $display("\tData_out=%d", data_out);
      $display("=============================================================");

   endfunction: display


   // Compare function
   // Compares expected (this) vs received transaction
   virtual function bit compare(input ram_trans rcvd, output string message);

      compare = 0;

      // Address mismatch check
      if (this.rd_address != rcvd.rd_address) begin
         $display($time);
         message = "--------- ADDRESS MISMATCH ---------";
         return 0;
      end

      // Data mismatch check
      if (this.data_out != rcvd.data_out) begin
         $display($time);
         message = "--------- DATA MISMATCH ---------";
         return 0;
      end

      // Successful comparison
      message = "SUCCESSFULLY COMPARED";
      return 1;

   endfunction: compare

endclass: ram_trans

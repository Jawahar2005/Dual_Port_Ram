interface ram_if(input bit clock);

   logic [63:0] data_in;
   logic [63:0] data_out;
   logic [11:0] rd_address;
   logic [11:0] wr_address;
   logic        read;
   logic        write;


   clocking wr_drv_cb @(posedge clock);
      default input #1 output #1;
      output wr_address;
      output data_in;
      output write;
   endclocking: wr_drv_cb


   clocking rd_drv_cb @(posedge clock);
      default input #1 output #1;
      output read;
      output rd_address;
   endclocking: rd_drv_cb


   clocking wr_mon_cb @(posedge clock);
      default input #1 output #1;
      input write;
      input wr_address;
      input data_in;
   endclocking: wr_mon_cb


   clocking rd_mon_cb @(posedge clock);
      default input #1 output #1;
      input read;
      input rd_address;
      input data_out;
   endclocking: rd_mon_cb

   modport WR_DRV_MP (clocking wr_drv_cb);

   modport RD_DRV_MP (clocking rd_drv_cb);

   modport WR_MON_MP (clocking wr_mon_cb);

   modport RD_MON_MP (clocking rd_mon_cb);

endinterface: ram_if


class ram_write_mon;

   virtual ram_if.WR_MON_MP wr_mon_if;

  
   ram_trans wrdata;
   ram_trans data2rm;

   mailbox #(ram_trans) mon2rm;

   function new(virtual ram_if.WR_MON_MP wr_mon_if,
                mailbox #(ram_trans) mon2rm);

      this.wr_mon_if = wr_mon_if;
      this.mon2rm    = mon2rm;

      this.wrdata = new;

   endfunction: new


   virtual task monitor();

      @(wr_mon_if.wr_mon_cb);

      wait (wr_mon_if.wr_mon_cb.write == 1);

      @(wr_mon_if.wr_mon_cb);

      begin
         wrdata.write      = wr_mon_if.wr_mon_cb.write;
         wrdata.wr_address = wr_mon_if.wr_mon_cb.wr_address;
         wrdata.data       = wr_mon_if.wr_mon_cb.data_in;

         wrdata.display("DATA FROM WRITE MONITOR");
      end

   endtask: monitor


   virtual task start();

      fork
         forever begin

            monitor();

            data2rm = new wrdata;

            mon2rm.put(data2rm);

         end
      join_none

   endtask: start

endclass: ram_write_mon

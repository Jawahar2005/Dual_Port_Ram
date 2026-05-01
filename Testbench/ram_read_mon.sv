
class ram_read_mon;

   virtual ram_if.RD_MON_MP rd_mon_if;

 
   ram_trans rddata, data2rm, data2sb;

   mailbox #(ram_trans) mon2rm;
   mailbox #(ram_trans) mon2sb;

   function new(virtual ram_if.RD_MON_MP rd_mon_if,
                mailbox #(ram_trans) mon2rm,
                mailbox #(ram_trans) mon2sb);

      this.rd_mon_if = rd_mon_if;
      this.mon2rm    = mon2rm;
      this.mon2sb    = mon2sb;

      this.rddata = new;

   endfunction: new


   virtual task monitor();

      @(rd_mon_if.rd_mon_cb);

      wait (rd_mon_if.rd_mon_cb.read == 1);

      @(rd_mon_if.rd_mon_cb);

      begin
         rddata.read       = rd_mon_if.rd_mon_cb.read;
         rddata.rd_address = rd_mon_if.rd_mon_cb.rd_address;
         rddata.data_out   = rd_mon_if.rd_mon_cb.data_out;

         rddata.display("DATA FROM READ MONITOR");
      end

   endtask: monitor


   virtual task start();

      fork
         forever begin

            monitor();

            data2sb = new rddata;
            data2rm = new rddata;

            mon2rm.put(data2rm);
            mon2sb.put(data2sb);

         end
      join_none

   endtask: start

endclass: ram_read_mon

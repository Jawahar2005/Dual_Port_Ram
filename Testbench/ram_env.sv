
class ram_env;

   virtual ram_if.WR_DRV_MP wr_drv_if;
   virtual ram_if.RD_DRV_MP rd_drv_if;
   virtual ram_if.WR_MON_MP wr_mon_if;
   virtual ram_if.RD_MON_MP rd_mon_if;

   mailbox #(ram_trans) gen2wr;   // Generator → Write Driver
   mailbox #(ram_trans) gen2rd;   // Generator → Read Driver
   mailbox #(ram_trans) rd2rm;    // Read Monitor → Reference Model
   mailbox #(ram_trans) wr2rm;    // Write Monitor → Reference Model
   mailbox #(ram_trans) rm2sb;    // Reference Model → Scoreboard
   mailbox #(ram_trans) mon2sb;   // Read Monitor → Scoreboard

   ram_gen        gen_h;
   ram_write_drv  wrdrv;
   ram_read_drv   rddrv;
   ram_write_mon  wrmon;
   ram_read_mon   rdmon;
   ram_model      rm;
   ram_sb         sb;

   function new (
      virtual ram_if.WR_DRV_MP wr_drv_if,
      virtual ram_if.RD_DRV_MP rd_drv_if,
      virtual ram_if.WR_MON_MP wr_mon_if,
      virtual ram_if.RD_MON_MP rd_mon_if
   );

      this.wr_drv_if = wr_drv_if;
      this.rd_drv_if = rd_drv_if;
      this.wr_mon_if = wr_mon_if;
      this.rd_mon_if = rd_mon_if;

      gen2wr  = new();
      gen2rd  = new();
      rd2rm   = new();
      wr2rm   = new();
      rm2sb   = new();
      mon2sb  = new();

   endfunction


   virtual task build();

      gen_h = new(gen2wr, gen2rd);

      wrdrv = new(wr_drv_if, gen2wr);
      rddrv = new(rd_drv_if, gen2rd);

      wrmon = new(wr_mon_if, wr2rm);
      rdmon = new(rd_mon_if, rd2rm, mon2sb);

      rm = new(wr2rm, rd2rm, rm2sb);

      sb = new(mon2sb, rm2sb);

   endtask


   virtual task reset_dut();

      rd_drv_if.rd_drv_cb.rd_address <= '0;
      rd_drv_if.rd_drv_cb.read       <= '0;

      wr_drv_if.wr_drv_cb.wr_address <= 0;
      wr_drv_if.wr_drv_cb.write      <= '0;

      repeat(5) @(wr_drv_if.wr_drv_cb);

      for (int i = 0; i < 4096; i++) begin
         wr_drv_if.wr_drv_cb.write      <= '1;
         wr_drv_if.wr_drv_cb.wr_address <= i;
         wr_drv_if.wr_drv_cb.data_in    <= '0;
         @(wr_drv_if.wr_drv_cb);
      end

      wr_drv_if.wr_drv_cb.write <= '0;

      repeat(5) @(wr_drv_if.wr_drv_cb);

   endtask : reset_dut


   virtual task start();

      fork
         gen_h.start();
         wrdrv.start();
         rddrv.start();
         wrmon.start();
         rdmon.start();
         rm.start();
         sb.start();
      join_none

   endtask


   virtual task stop();

      wait(sb.DONE.triggered);

   endtask : stop 


   virtual task run();

      reset_dut();  
      start();       
      stop();        
     sb.report();   

   endtask

endclass : ram_env

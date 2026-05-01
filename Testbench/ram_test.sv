
class ram_trans_extnd1 extends ram_trans;

   constraint CONST_WR_ADD { write == 1; wr_address inside {0,4095}; }
   constraint CONST_RD_ADD { rd_address inside {0,4095}; }
   constraint CONST_DATA   { write == 1; data inside {[501:1000], [2501:3000]}; }

endclass


class ram_trans_extnd2 extends ram_trans;

   constraint CONST_DATA_1 { data == 4294; }
   constraint CONST_WR_ADD { write == 1; wr_address inside {0,4095}; }
   constraint CONST_RD_ADD { rd_address inside {0,4095}; }

endclass


class ram_base_test;

   virtual ram_if.WR_DRV_MP wr_drv_if;
   virtual ram_if.RD_DRV_MP rd_drv_if;
   virtual ram_if.WR_MON_MP wr_mon_if;
   virtual ram_if.RD_MON_MP rd_mon_if;

   ram_env env_h;

   function new(virtual ram_if.WR_DRV_MP wr_drv_if,
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);

      this.wr_drv_if = wr_drv_if;
      this.rd_drv_if = rd_drv_if;
      this.wr_mon_if = wr_mon_if;
      this.rd_mon_if = rd_mon_if;

      env_h = new(wr_drv_if, rd_drv_if, wr_mon_if, rd_mon_if);

   endfunction: new


   virtual task build();
      env_h.build();
   endtask: build


   virtual task run();
      env_h.run();
   endtask: run

endclass: ram_base_test


class ram_test_extnd1 extends ram_base_test;

   ram_trans_extnd1 data_h1;

   function new(virtual ram_if.WR_DRV_MP wr_drv_if,
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);

      super.new(wr_drv_if, rd_drv_if, wr_mon_if, rd_mon_if);

   endfunction: new


   virtual task build();
      super.build();
   endtask: build


   virtual task run();

      data_h1 = new();

      env_h.gen_h.gen_trans = data_h1;

      super.run();

   endtask: run

endclass: ram_test_extnd1


class ram_test_extnd2 extends ram_base_test;

   ram_trans_extnd2 data_h2;

   function new(virtual ram_if.WR_DRV_MP wr_drv_if,
                virtual ram_if.RD_DRV_MP rd_drv_if,
                virtual ram_if.WR_MON_MP wr_mon_if,
                virtual ram_if.RD_MON_MP rd_mon_if);

      super.new(wr_drv_if, rd_drv_if, wr_mon_if, rd_mon_if);

   endfunction


   virtual task build();
      super.build();
   endtask


   virtual task run();

      data_h2 = new();

      env_h.gen_h.gen_trans = data_h2;

      super.run();

   endtask

endclass: ram_test_extnd2

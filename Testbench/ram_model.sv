
class ram_model;


   ram_trans wrmon_data;
   ram_trans rdmon_data;

   logic [63:0] ref_data[int];

   mailbox #(ram_trans) wr2rm;
   mailbox #(ram_trans) rd2rm;
   mailbox #(ram_trans) rm2sb;

   function new(mailbox #(ram_trans) wr2rm,
                mailbox #(ram_trans) rd2rm,
                mailbox #(ram_trans) rm2sb);
      this.wr2rm = wr2rm;
      this.rd2rm = rd2rm;
      this.rm2sb = rm2sb;
   endfunction: new

   virtual task dual_mem_fun_write(ram_trans wrmon_data);
      begin
         if (wrmon_data.write)
            mem_write(wrmon_data);
      end
   endtask: dual_mem_fun_write

   virtual task dual_mem_fun_read(ram_trans rdmon_data);
      begin
         if (rdmon_data.read)
            mem_read(rdmon_data);
      end
   endtask: dual_mem_fun_read

   virtual task mem_write(ram_trans wrmon_data);
      ref_data[wrmon_data.wr_address] = wrmon_data.data;
   endtask: mem_write

   virtual task mem_read(inout ram_trans rdmon_data);
      if (ref_data.exists(rdmon_data.rd_address))
         rdmon_data.data_out = ref_data[rdmon_data.rd_address];
   endtask: mem_read

   virtual task start();

      fork
         begin
            fork
               
               begin
                  forever begin
                     wr2rm.get(wrmon_data);

                     dual_mem_fun_write(wrmon_data);
                  end
               end

               begin
                  forever begin
                     rd2rm.get(rdmon_data);

                     dual_mem_fun_read(rdmon_data);

                     rm2sb.put(rdmon_data);
                  end
               end

            join
         end
      join_none

   endtask: start

endclass: ram_model

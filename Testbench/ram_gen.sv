class ram_gen;

   ram_trans gen_trans;

   ram_trans data2send;

   mailbox #(ram_trans) gen2rd;
   mailbox #(ram_trans) gen2wr;

   
   function new(mailbox #(ram_trans) gen2rd,
                mailbox #(ram_trans) gen2wr);
      this.gen_trans = new;
      this.gen2rd    = gen2rd;
      this.gen2wr    = gen2wr;
   endfunction: new

   virtual task start();
      fork
         begin
            for(int i=0; i<number_of_transactions; i++)
               begin
                  assert(gen_trans.randomize());
                  data2send = new gen_trans;
                  gen2rd.put(data2send);
                  gen2wr.put(data2send);
               end
                                                                                       end
      join_none
   endtask: start

endclass: ram_gen

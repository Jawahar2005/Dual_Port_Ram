/********************************************************************************************
Synchronous Dual Port RAM
********************************************************************************************/

module dual_mem (
   input  clk,                        // Clock
   input  mem_en,                     // Memory enable
   input  op_en,                      // Output enable
   input  [63:0] data_in,             // Input data
   input  [9:0]  rd_address,          // Read address
   input  [9:0]  wr_address,          // Write address
   input  read,                       // Read control
   input  write,                      // Write control
   output reg [63:0] data_out         // Output data
);

   // Parameters (can be used instead of fixed values)
   parameter RAM_WIDTH = 64;
   parameter RAM_DEPTH = 1024;
   parameter ADDR_SIZE = 10;

   // Memory declaration
   reg [RAM_WIDTH-1:0] memory [RAM_DEPTH-1:0];


   // ================= WRITE OPERATION =================
   always @(posedge clk) begin
      if (mem_en) begin
         if (write) begin
            memory[wr_address] <= data_in;
         end
      end
   end


   // ================= READ OPERATION =================
   always @(posedge clk) begin
      if (op_en) begin
         if (read) begin
            data_out <= memory[rd_address];
         end
      end
      else begin
         data_out <= 64'bz;  // High impedance when disabled
      end
   end

endmodule


/********************************************************************************************
2:4 Decoder Module (Used for Address Expansion)
********************************************************************************************/

module mem_dec (
   input  mem_in1,   // Input bit 1
   input  mem_in0,   // Input bit 0

   output reg mem_out3,  // Output line 3
   output reg mem_out2,  // Output line 2
   output reg mem_out1,  // Output line 1
   output reg mem_out0   // Output line 0
);

   // Combinational logic for decoding
   always @(*) begin
      case ({mem_in1, mem_in0})

         2'b00 : {mem_out3, mem_out2, mem_out1, mem_out0} = 4'b0001;
         2'b01 : {mem_out3, mem_out2, mem_out1, mem_out0} = 4'b0010;
         2'b10 : {mem_out3, mem_out2, mem_out1, mem_out0} = 4'b0100;
         2'b11 : {mem_out3, mem_out2, mem_out1, mem_out0} = 4'b1000;

      endcase
   end

endmodule



/********************************************************************************************
4096 x 64 Dual Port RAM using Memory Banking + Decoder
********************************************************************************************/

`define RAM_WIDTH 64
`define ADDR_SIZE 12

module ram_4096 (
   input clk,                               // Clock
   input [`RAM_WIDTH-1:0] data_in,           // Input data
   input [`ADDR_SIZE-1:0] rd_address,        // Read address (12-bit)
   input [`ADDR_SIZE-1:0] wr_address,        // Write address (12-bit)
   input read,                              // Read control
   input write,                             // Write control
   output tri [`RAM_WIDTH-1:0] data_out      // Tri-state output
);

   // Write decoder outputs
   wire mem_wr0, mem_wr1, mem_wr2, mem_wr3;

   // Read decoder outputs
   wire mem_rd0, mem_rd1, mem_rd2, mem_rd3;


   // ================= WRITE ADDRESS DECODER =================
   mem_dec wr_add_dec (
      .mem_in1 (wr_address[`ADDR_SIZE-1]),
      .mem_in0 (wr_address[`ADDR_SIZE-2]),
      .mem_out3(mem_wr3),
      .mem_out2(mem_wr2),
      .mem_out1(mem_wr1),
      .mem_out0(mem_wr0)
   );


   // ================= READ ADDRESS DECODER =================
   mem_dec rd_add_dec (
      .mem_in1 (rd_address[`ADDR_SIZE-1]),
      .mem_in0 (rd_address[`ADDR_SIZE-2]),
      .mem_out3(mem_rd3),
      .mem_out2(mem_rd2),
      .mem_out1(mem_rd1),
      .mem_out0(mem_rd0)
   );


   // ================= MEMORY BANKS =================
   // Each dual_mem = 1024 locations → 4 × 1024 = 4096

   dual_mem DM_0 (
      .clk(clk),
      .mem_en(mem_wr0),                       // Write enable for bank 0
      .op_en(mem_rd0),                        // Read enable for bank 0
      .data_in(data_in),
      .rd_address(rd_address[`ADDR_SIZE-3:0]),
      .wr_address(wr_address[`ADDR_SIZE-3:0]),
      .read(read),
      .write(write),
      .data_out(data_out)
   );

   dual_mem DM_1 (
      .clk(clk),
      .mem_en(mem_wr1),
      .op_en(mem_rd1),
      .data_in(data_in),
      .rd_address(rd_address[`ADDR_SIZE-3:0]),
      .wr_address(wr_address[`ADDR_SIZE-3:0]),
      .read(read),
      .write(write),
      .data_out(data_out)
   );

   dual_mem DM_2 (
      .clk(clk),
      .mem_en(mem_wr2),
      .op_en(mem_rd2),
      .data_in(data_in),
      .rd_address(rd_address[`ADDR_SIZE-3:0]),
      .wr_address(wr_address[`ADDR_SIZE-3:0]),
      .read(read),
      .write(write),
      .data_out(data_out)
   );

   dual_mem DM_3 (
      .clk(clk),
      .mem_en(mem_wr3),
      .op_en(mem_rd3),
      .data_in(data_in),
      .rd_address(rd_address[`ADDR_SIZE-3:0]),
      .wr_address(wr_address[`ADDR_SIZE-3:0]),
      .read(read),
      .write(write),
      .data_out(data_out)
   );

endmodule

`timescale 1ns / 1ps

/* Module Description 
    1. This module is used to generate write pointer and full signal for the FIFO.
    Port Descriptions
        wr_clk : Write clock
        wr_rst_n : Write reset (active low)
        wr_en : Write enable
        gry_rd_ptr_sync : Synchronized read pointer from the read clock domain
        gry_wr_ptr : Gray coded write pointer for the read clock domain
        bin_wr_addr : Binary write address for the FIFO memory
        full : Full flag indicating FIFO is full
    2. Important Notes
        - Full condition is checked with respect to the next write_pointer in the current cycle and making the full high in the next cycle
        - Current binary wr_addr is given to the FIFO memory for writing the data
*/

module wr_ptr_and_full #(parameter A_WIDTH = 5)
(
    input                      wr_clk,
    input                      wr_rst_n,
    input                      wr_en,
    input        [A_WIDTH : 0] gry_rd_ptr_sync,
    output logic [A_WIDTH : 0] gry_wr_ptr,
    output logic [A_WIDTH : 0] bin_wr_addr,
    output logic               full
);

   logic [A_WIDTH : 0] b_wr_ptr_nxt;
   logic [A_WIDTH : 0] g_wr_ptr_nxt;
   logic full_w;

   assign b_wr_ptr_nxt = bin_wr_addr + (wr_en & !full);
   assign g_wr_ptr_nxt = b_wr_ptr_nxt ^ (b_wr_ptr_nxt >> 1);

   always_ff @(posedge wr_clk, negedge wr_rst_n)
   begin
    if(!wr_rst_n)
    begin
        gry_wr_ptr  <= '0;
        bin_wr_addr <= '0;
    end
    else 
    begin
        gry_wr_ptr  <= g_wr_ptr_nxt;
        bin_wr_addr <= b_wr_ptr_nxt;
    end
   end

   always_ff @(posedge wr_clk, negedge wr_rst_n)
   begin
    if(!wr_rst_n)
        full <= 1'b0;
    else
        full <= full_w;
   end

   assign full_w = (g_wr_ptr_nxt == {~gry_rd_ptr_sync[A_WIDTH : A_WIDTH - 1], gry_rd_ptr_sync[A_WIDTH - 2 : 0]});
 
endmodule

`timescale 1ns / 1ps

/*  Module Description 
    1. This module is used to generate read pointer and empty signal for the FIFO.
    Port Descriptions
        rd_clk : Read clock
        rd_rst_n : Read reset (active low)
        rd_en : Read enable signal
        gry_wr_ptr_sync : Synchronized write pointer from the write clock domain
        gry_rd_ptr : Gray coded read pointer for the write clock domain
        bin_rd_addr : Binary read address for the FIFO memory
        empty : Empty flag indicating FIFO is empty
    2. Important Notes
        - Empty condition is checked with respect to the next read_pointer in the current cycle and making the empty high in the next cycle
        - Current binary rd_addr is given to the FIFO memory for reading the data

*/

module rd_ptr_and_empty #(parameter A_WIDTH = 5)
(
    input                      rd_clk,
    input                      rd_rst_n,
    input                      rd_en,
    input        [A_WIDTH : 0] gry_wr_ptr_sync,
    output logic [A_WIDTH : 0] gry_rd_ptr,
    output logic [A_WIDTH : 0] bin_rd_addr,
    output logic               empty
);

    logic [A_WIDTH : 0] b_rd_ptr_nxt;
    logic [A_WIDTH : 0] g_rd_ptr_nxt;
    logic empty_w;

    assign b_rd_ptr_nxt = bin_rd_addr + (rd_en & !empty);
    assign g_rd_ptr_nxt = b_rd_ptr_nxt ^ (b_rd_ptr_nxt >> 1);

    always_ff @ (posedge rd_clk, negedge rd_rst_n)
    begin
        if(!rd_rst_n)
        begin
            gry_rd_ptr  <= '0;
            bin_rd_addr <= '0;
        end
        else
        begin
            gry_rd_ptr  <= g_rd_ptr_nxt;
            bin_rd_addr <= b_rd_ptr_nxt;
        end
    end

    always_ff @ (posedge rd_clk, negedge rd_rst_n)
    begin
        if(!rd_rst_n)
            empty <= 1'b1;
        else
            empty <= empty_w;
    end

    assign empty_w = (gry_wr_ptr_sync == g_rd_ptr_nxt);

endmodule

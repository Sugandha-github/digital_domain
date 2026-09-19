`timescale 1ns / 1ps

/*THis module implements an asynchronous FIFO */

module a_fifo_top #(parameter D_WIDTH = 32, DEPTH = 32)
(
    input                    wr_clk, rd_clk,
    input                    wr_rst_n, rd_rst_n,
    input                    wr_en, rd_en,
    input  [D_WIDTH - 1 : 0] wr_data,
    output [D_WIDTH - 1 : 0] rd_data,
    output                   full,
    output                   empty
);

    localparam A_WIDTH = $clog2(DEPTH);

    wire [A_WIDTH : 0]     wr_addr, rd_addr;
    wire [A_WIDTH : 0]     gry_wr_ptr, gry_rd_ptr;   
    wire [A_WIDTH : 0]     gry_wr_ptr_sync, gry_rd_ptr_sync;
    
    fifo_memory #(.D_WIDTH(D_WIDTH), .A_WIDTH(A_WIDTH))
    fifo_mem(
        .wr_clk(wr_clk),
        .wr_en(wr_en),
        .full(full),
        .wr_addr(wr_addr[A_WIDTH - 1 : 0]),
        .rd_addr(rd_addr[A_WIDTH - 1 : 0]),
        .wr_data(wr_data),
        .rd_data(rd_data)
    );
    
    two_stage_synchronizer #(.A_WIDTH(A_WIDTH))
    w2r_sync(
        .clk(rd_clk),       // Destination Clock
        .rst_n(rd_rst_n),   // Destination reset
        .i_ptr(gry_wr_ptr), // Source Pointer to reach the destination
        .o_ptr(gry_wr_ptr_sync)
    );
    
    two_stage_synchronizer #(.A_WIDTH(A_WIDTH))
    r2w_sync(
        .clk(wr_clk),       // Destination Clock
        .rst_n(wr_rst_n),   // Destination reset
        .i_ptr(gry_rd_ptr), // Source Pointer to reach the destination
        .o_ptr(gry_rd_ptr_sync)
    );
    
    wr_ptr_and_full #(.A_WIDTH(A_WIDTH))
    write_ptr_and_full(
        .wr_clk(wr_clk),
        .wr_rst_n(wr_rst_n),
        .wr_en(wr_en),
        .gry_rd_ptr_sync(gry_rd_ptr_sync),
        .gry_wr_ptr(gry_wr_ptr),
        .bin_wr_addr(wr_addr),
        .full(full)
    );
    
    rd_ptr_and_empty #(.A_WIDTH(A_WIDTH))
    read_ptr_and_empty(
        .rd_clk(rd_clk),
        .rd_rst_n(rd_rst_n),
        .rd_en(rd_en),
        .gry_wr_ptr_sync(gry_wr_ptr_sync),
        .gry_rd_ptr(gry_rd_ptr),
        .bin_rd_addr(rd_addr),
        .empty(empty)
    );

endmodule

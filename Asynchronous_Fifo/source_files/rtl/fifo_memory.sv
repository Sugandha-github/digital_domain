`timescale 1ns / 1ps

module fifo_memory #(parameter D_WIDTH = 32, A_WIDTH = 6)
(
    input                    wr_clk,
    input                    wr_en,
    input                    full,
    input  [A_WIDTH - 1 : 0] wr_addr,
    input  [A_WIDTH - 1 : 0] rd_addr,
    input  [D_WIDTH - 1 : 0] wr_data,
    output [D_WIDTH - 1 : 0] rd_data
);

    localparam DEPTH = 1 << A_WIDTH;
    logic [D_WIDTH - 1 : 0] mem [0 : DEPTH - 1];
    
    always_ff @(posedge wr_clk)
    begin
        if(wr_en && !full)
            mem[wr_addr]    <=  wr_data;
    end
    
    assign rd_data  =   mem[rd_addr];

endmodule

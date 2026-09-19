`timescale 1ns / 1ps

module tb_a_fifo_top;
    parameter D_WIDTH = 32, DEPTH = 32;
    reg  wr_clk, rd_clk, wr_rst_n, rd_rst_n;
    reg  wr_en, rd_en;
    reg  [D_WIDTH - 1 : 0] wr_data;
    wire [D_WIDTH - 1 : 0] rd_data;
    wire full, empty;
    
//    async_fifo_inf #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH)) inf();

    a_fifo_top #(.D_WIDTH(D_WIDTH), .DEPTH(DEPTH))
    dut(
        .wr_clk(wr_clk),
        .rd_clk(rd_clk),
        .wr_rst_n(wr_rst_n),
        .rd_rst_n(rd_rst_n),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_data(wr_data),
        .rd_data(rd_data),
        .full(full),
        .empty(empty)
    );
    
    // 100 MHz wr_clk
    always #5 wr_clk = !wr_clk;
    // 50 MHz rd_clk
    always #10 rd_clk = !rd_clk;
    
    initial begin
        wr_clk = 1;
        rd_clk = 1;
    end
    
    // Test Cases : 
    // 1. Reset Check
    // 2. Write 1 data
    // 3. Read 1 data
    // 4. Write until Full
    // 5. Read until Empty
    // 6. Consecutive Writes and Reads
    // 7. Reset in between writes and reads
    // 8.Try to write when full and read when empty

    initial begin

        // Test Case 1 : Reset Check
        wr_rst_n = 1'b0;
        rd_rst_n = 1'b0;
        wr_en    = 1'b0;
        rd_en    = 1'b0;
        fork begin
        repeat(5) @(posedge wr_clk);
        wr_rst_n = 1'b1;
        end begin
        repeat(5) @(posedge rd_clk);
        rd_rst_n = 1'b1;
        end join
        ////////////////////////////

        // Test Case 2 : Write 1 data
        @(posedge wr_clk);
        wr_en = 1'b1;
        wr_data = 32'h12234231;
        repeat(1) @(posedge wr_clk);
        wr_en = 1'b0;
        ////////////////////////////

        // Test Case 2 : Write 1 data
        @(posedge wr_clk);
        wr_en = 1'b1;
        repeat(1) @(posedge wr_clk);
        wr_en = 1'b0;
        wr_data = 32'h11919026;
        ////////////////////////////

        // Test Case 3 : Read 1 data
        @(posedge rd_clk);
        rd_en = 1'b1;
        repeat(2) @(posedge rd_clk);
        rd_en = 1'b0;
        ////////////////////////////

        // Test Case 4 : Write until Full
        repeat(2) @(posedge wr_clk);
        repeat(DEPTH) begin
            wr_data = wr_data + 1;
            wr_en = 1'b1;
            @(posedge wr_clk);
        end
        wr_en = 1'b0;
        ////////////////////////////

        // Test Case 5 : Read Till empty
        repeat(2) @(posedge rd_clk);
        repeat(DEPTH) begin
            rd_en = 1'b1;
            @(posedge rd_clk);
        end
        @(posedge rd_clk);
        rd_en = 1'b0;
        @(posedge rd_clk);
        ////////////////////////////
        
        // Test Case 6 : Consecutive Writes and Reads
        @(posedge wr_clk);
        wr_data = 32'h00000001;
        @(posedge rd_clk);
        repeat(16)
        begin
            @(posedge wr_clk);
            wr_data = wr_data + 1;
            wr_en = 1'b1;
            @(posedge wr_clk);
            wr_en = 1'b0;
            @(posedge rd_clk);
            rd_en = 1'b1;
            @(posedge rd_clk);
            rd_en = 1'b0;
        end

        // Test Case 7 : Reset in between writes and reads
        @(posedge wr_clk);
        wr_data = 32'hAAAA4444;
        wr_en = 1'b1;
        repeat(10)
        begin
            @(posedge wr_clk);
            wr_data = wr_data + 1;
            @(posedge rd_clk);
            rd_en = 1'b1;
        end
        wr_rst_n = 1'b0;
        wr_en = 1'b0;
        rd_rst_n = 1'b0;
        rd_en = 1'b0;
        @(posedge wr_clk);
        wr_rst_n = 1'b1;
        @(posedge rd_clk);
        rd_rst_n = 1'b1;
        wr_data = 32'hBBBB5555;
        wr_en = 1'b1;
        repeat(5)
        begin
            @(posedge wr_clk);
            wr_data = wr_data + 1; 
            @(posedge rd_clk);
            rd_en = 1'b1;
        end

        // Test Case 8 : Try to write when full and read when empty 

        $finish();
    end

endmodule

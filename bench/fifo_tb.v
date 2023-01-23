`timescale 1ns/1ps

module fifo_tb();
    parameter DATA_LEN = 32;
    parameter ADDR_LEN = 8;

    reg clk, rst, wincr, rincr;
    reg [DATA_LEN-1 : 0] wdata;

    wire [DATA_LEN-1 : 0] rdata;
    wire empty, full;

    

    async_fifo #(DATA_LEN, ADDR_LEN) 
        DUT(   
            .clk(clk), .rst_n(rst), .wincr_i(wincr), .rincr_i(rincr),
            .wdata_i(wdata),

            .rdata_o(rdata),
            .rempty_o(empty) ,.wfull_o(full)
            );

    initial clk = 0;
    always # 10 clk = !clk;
    integer  i;
    initial begin
        rst = 0;
        wdata = 32'hF;
        wincr = 0;
        rincr = 0;
        #800
        rst = 1;
        #100
        wincr = 1;
        rincr = 1;
        for (i=0; i <1000; i=i+1) begin
            wdata = $random();
            #20;
        end
        wincr = 0;
        #10000
        $finish;
    end 

endmodule
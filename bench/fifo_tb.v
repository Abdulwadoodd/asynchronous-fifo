`timescale 1ns/1ps

module fifo_tb();
    parameter DATA_LEN = 32;
    parameter ADDR_LEN = 4;
    parameter WCLOCK_PERIOD = 11.4; // (wclk  ~87.71 Mhz)
    parameter RCLOCK_PERIOD = 13.5; // (rclk  ~74.07 Mhz)
    // input to the DUT
    reg wclk, rclk, rst_n, write_en, read_en;
    reg [DATA_LEN-1 : 0] wdata;
    // output from DUT
    wire [DATA_LEN-1 : 0] rdata;
    wire empty, full;
    // DUT Instantiation
    async_fifo_wrapper #(DATA_LEN, ADDR_LEN) 
        DUT(   
            .wclk(wclk), .rclk(rclk), .rst_n(rst_n), .write_en(write_en), .read_en(read_en),
            .wdata_i(wdata),

            .rdata_o(rdata),
            .rempty_o(empty) ,.wfull_o(full)
            );

    // read and write clocks for corresponding domains
    initial begin
        wclk=0; 
        rclk=0;
    end
    
    always # (WCLOCK_PERIOD/2) rclk = !rclk;
    always # (RCLOCK_PERIOD/2) wclk = !wclk;

    integer  i;
    initial begin
        rst_n = 0;
        wdata = 32'hFFFFFFFF;
        write_en = 0;
        read_en = 0;
        #100
        rst_n = 1;
        #100
        write_en = 1;
        read_en = 1;
        for (i=0; i <1000; i=i+1) begin
            if (!full) wdata = $random();
            # (WCLOCK_PERIOD);
        end
        write_en = 0;
        #500
        $finish;
    end 

endmodule
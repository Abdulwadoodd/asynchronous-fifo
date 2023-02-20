`timescale 1ns/1ps

module exp_tb();

    parameter DATA_LEN = 8;
    parameter ADDR_LEN = 4;
    //parameter WCLOCK_PERIOD = 11.4; // (wclk  ~87.71 Mhz)
    //parameter RCLOCK_PERIOD = 13.5; // (rclk  ~74.07 Mhz)

    parameter WCLOCK_PERIOD = 10; // (wclk  100 Mhz)
    parameter RCLOCK_PERIOD = 20; // (rclk  50 Mhz)

    reg clk, rst_n;
    wire full;
    wire [DATA_LEN-1:0] data_out;

    exp_top #(DATA_LEN, ADDR_LEN) 
        DUT(
            .clk(clk), .rst_n(rst_n),
            .full1(full),
            .data_out(data_out)
        );
    
    initial clk = 0;
    always #5 clk = !clk;

    // initial begin
    //     wclk=0; 
    //     rclk=0;
    // end
    
    // always # (WCLOCK_PERIOD/2) wclk = !wclk;
    // always # (RCLOCK_PERIOD/2) rclk = !rclk;

    initial begin
        rst_n = 0;
        #500
        rst_n = 1;
    end

endmodule

module async_fifo_wrapper #(DATA_LEN = 32,
                            ADDR_LEN = 8) 
    (
    input                   wclk, rclk, rst_n, write_en, read_en,
    input  [DATA_LEN-1 : 0] wdata_i,

    output [DATA_LEN-1 : 0] rdata_o,
    output                  rempty_o ,wfull_o);


    async_fifo #(DATA_LEN, ADDR_LEN) 
        async_fifo_core(   
            .wclk(wclk), .rclk(rclk), .rst_n(rst_n), .write_en(write_en), .read_en(read_en),
            .data_in(wdata_i),

            .data_out(rdata_o),
            .empty(rempty_o), .full(wfull_o)
            );


    // /////////////////////////////////////////////////////////////////
    // // Using 7 series FPGAs PLL primitive for clock gen.
    // // CLKOUT0 = Fclkin * (CLKFBOUT_MULT / CLKOUT0_DIVIDE)
    // wire clkfbw, clkfbr;
    // // clk for write domain = 85MHz = 100*(17/20)
    // PLLE2_BASE
    //  #(.BANDWIDTH("OPTIMIZED"),
    //    .CLKFBOUT_MULT(17),
    //    .CLKIN1_PERIOD(10.0), //100MHz
    //    .CLKOUT0_DIVIDE(20),
    //    .DIVCLK_DIVIDE(1),
    //    .STARTUP_WAIT("FALSE"))
    // wclk_gen
    //  (.CLKOUT0(wclk),
    //   .CLKOUT1(),
    //   .CLKOUT2(),
    //   .CLKOUT3(),
    //   .CLKOUT4(),
    //   .CLKOUT5(),
    //   .CLKFBOUT(clkfbw),
    //   .LOCKED(),
    //   .CLKIN1(clk),
    //   .PWRDWN(1'b0),
    //   .RST(1'b0),
    //   .CLKFBIN(clkfbw));
    // // clk for read domain = 76MHz
    // PLLE2_BASE
    //  #(.BANDWIDTH("OPTIMIZED"),
    //    .CLKFBOUT_MULT(12),
    //    .CLKIN1_PERIOD(10.0), //100MHz
    //    .CLKOUT0_DIVIDE(20),
    //    .DIVCLK_DIVIDE(1),
    //    .STARTUP_WAIT("FALSE"))
    // rclk_gen
    //  (.CLKOUT0(rclk),
    //   .CLKOUT1(),
    //   .CLKOUT2(),
    //   .CLKOUT3(),
    //   .CLKOUT4(),
    //   .CLKOUT5(),
    //   .CLKFBOUT(clkfbr),
    //   .LOCKED(),
    //   .CLKIN1(clk),
    //   .PWRDWN(1'b0),
    //   .RST(1'b0),
    //   .CLKFBIN(clkfbr));
    // ////////////////////////////////////////////////////////////////
    
endmodule
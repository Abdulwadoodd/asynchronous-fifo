
module fifo_wrapper #(parameter DATA_LEN = 32,
                            parameter ADDR_LEN = 8) 
    (
    input                   wclk, rclk, rst_n, write_en, read_en,
    input  [DATA_LEN-1 : 0] wdata_i,

    output [DATA_LEN-1 : 0] rdata_o,
    output                  rempty_o ,wfull_o);

    wire [DATA_LEN-1 : 0] data_out;
    wire full, empty, rd_en1;
    reg wr_en2;

    assign rd_en1 = !full;
    async_fifo #(DATA_LEN, ADDR_LEN) 
        async_fifo_core1(   
            .wclk(wclk), .rclk(rclk), .rst_n(rst_n), .write_en(write_en), .read_en(rd_en1),
            .data_in(wdata_i),

            .data_out(data_out),
            .empty(empty), .full(wfull_o)
            );

    always @(posedge rclk ) wr_en2 <= !empty;

    async_fifo #(DATA_LEN, ADDR_LEN) 
        async_fifo_core2(   
            .wclk(rclk), .rclk(wclk), .rst_n(rst_n), .write_en(wr_en2), .read_en(read_en),
            .data_in(data_out),

            .data_out(rdata_o),
            .empty(rempty_o), .full(full)
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
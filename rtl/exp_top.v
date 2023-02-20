
module exp_top #(parameter DATA_LEN = 8,
                 parameter ADDR_LEN = 8) 
    (
    input  clk, rst_n,
    output full1,
    output [DATA_LEN-1 : 0] data_out);

    wire rclk, wclk;
    wire write_en, read_en; // inputs
    wire empty2 ;           // outputs
    wire [DATA_LEN-1 : 0] data_in;

    assign read_en = empty2 ? 0 : 1;

    // random data generation using LFSR
    rand_lfsr #(DATA_LEN) 
        rand_num(
            .rst_n(rst_n), .clk(wclk),
            .valid(write_en),
            .rnd_num(data_in)
        );

    fifo_wrapper #(DATA_LEN, ADDR_LEN) 
        fifo_wrap(
            .wclk(wclk), .rclk(rclk), .rst_n(rst_n), .write_en(write_en), .read_en(read_en),
            .wdata_i(data_in),

            .rdata_o(data_out),
            .rempty_o(empty2) , .wfull_o(full1)
        );



    /////////////////////////////////////////////////////////////////
    // Using 7 series FPGAs PLL primitive for clock gen.
    // CLKOUT0 = Fclkin * (CLKFBOUT_MULT / CLKOUT0_DIVIDE)
    wire clkfbw, clkfbr;
    // clk for write domain = 85MHz = 100*(17/20)
    PLLE2_BASE
     #(.BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT(17),
       .CLKIN1_PERIOD(10.0), //100MHz
       .CLKOUT0_DIVIDE(20),
       .DIVCLK_DIVIDE(1),
       .STARTUP_WAIT("FALSE"))
    wclk_gen
     (.CLKOUT0(wclk),
      .CLKOUT1(),
      .CLKOUT2(),
      .CLKOUT3(),
      .CLKOUT4(),
      .CLKOUT5(),
      .CLKFBOUT(clkfbw),
      .LOCKED(),
      .CLKIN1(clk),
      .PWRDWN(1'b0),
      .RST(1'b0),
      .CLKFBIN(clkfbw));
    // clk for read domain = 60 MHz = 100*(12/20)
    PLLE2_BASE
     #(.BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_MULT(12),
       .CLKIN1_PERIOD(10.0), //100MHz
       .CLKOUT0_DIVIDE(20),
       .DIVCLK_DIVIDE(1),
       .STARTUP_WAIT("FALSE"))
    rclk_gen
     (.CLKOUT0(rclk),
      .CLKOUT1(),
      .CLKOUT2(),
      .CLKOUT3(),
      .CLKOUT4(),
      .CLKOUT5(),
      .CLKFBOUT(clkfbr),
      .LOCKED(),
      .CLKIN1(clk),
      .PWRDWN(1'b0),
      .RST(1'b0),
      .CLKFBIN(clkfbr));
    ////////////////////////////////////////////////////////////////
    
endmodule
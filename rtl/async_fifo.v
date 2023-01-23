
module async_fifo #(DATA_LEN = 32,
                    ADDR_LEN = 8) 
    (
    input                   clk, rst_n, wincr_i, rincr_i,
    input  [DATA_LEN-1 : 0] wdata_i,

    output [DATA_LEN-1 : 0] rdata_o,
    output                  rempty_o ,wfull_o);
    
    wire wclk, rclk;
    wire [ADDR_LEN : 0] r2wptr, w2rptr, wptr, rptr;
    wire [ADDR_LEN-1 : 0] waddr, raddr;
    wire clkfbw, clkfbr;

    /////////////////////////////////////////////////////////////////
    // Using 7 series FPGAs PLL primitive for clock gen.
    // CLKOUT0 = Fclkin * (CLKFBOUT_MULT / CLKOUT0_DIVIDE)

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
    // clk for read domain = 76MHz
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

    fifo_mem #(ADDR_LEN,DATA_LEN)
        ram(
            .wclk(wclk), .wen_i(wincr_i & !wfull_o),
            .waddr(waddr), .raddr(raddr),
            .wdata(wdata_i), 
            .rdata(rdata_o)
        );


    sync #(ADDR_LEN)
        sync_w2r (
            .clk(rclk), .rst_n(rst_n),
            .sync_i(wptr),
            .sync_o(w2rptr) 
        );
    
    
    sync #(ADDR_LEN )
        sync_r2w (
            .clk(wclk), .rst_n(rst_n),
            .sync_i(rptr),
            .sync_o(r2wptr) 
        );
    
    wptr_ctrl #(ADDR_LEN)   
        wptr_hndl(
            .wclk(wclk), .wrst_n(rst_n), .wincr_i(wincr_i),
            .r2wptr_sync_i(r2wptr),

            .fifo_waddr_o(waddr),
            .wptr_o(wptr),
            .wfull_o(wfull_o)
        );

    rptr_ctrl #(ADDR_LEN)
        rptr_hndl(
        .rclk(rclk), .rrst_n(rst_n), .rincr_i(rincr_i),
        .w2rptr_sync_i(w2rptr),

        .fifo_raddr_o(raddr),
        .rptr_o(rptr),
        .rempty_o(rempty_o)
        );

endmodule
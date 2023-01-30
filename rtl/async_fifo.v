
module async_fifo #(DATA_LEN = 32,
                    ADDR_LEN = 8) 
    (
    input                   wclk, rclk, rst_n, write_en, read_en,
    input  [DATA_LEN-1 : 0] data_in,

    output [DATA_LEN-1 : 0] data_out,
    output                  empty ,full);

    // Internal Signals
    wire [ADDR_LEN : 0] r2wptr, w2rptr, wptr, rptr;
    wire [ADDR_LEN-1 : 0] waddr, raddr;

    // FIFI Memory (Dual port RAM) Inst.
    fifo_mem #(ADDR_LEN,DATA_LEN)
        ram(
            .wclk(wclk), .rclk(rclk), .wen_i(write_en & !full), .ren_i(read_en & !empty),
            .waddr(waddr), .raddr(raddr),
            .wdata(data_in), 
            .rdata(data_out)
        );

    // Write pointer Synchronizer (in read domain)
    sync #(ADDR_LEN)
        sync_w2r (
            .clk(rclk), .rst_n(rst_n),
            .sync_i(wptr),
            .sync_o(w2rptr) 
        );
    
    // Read pointer Synchronizer (in write domain)
    sync #(ADDR_LEN )
        sync_r2w (
            .clk(wclk), .rst_n(rst_n),
            .sync_i(rptr),
            .sync_o(r2wptr) 
        );

    // Write pointer controller
    wptr_ctrl #(ADDR_LEN)   
        wptr_hndl(
            .wclk(wclk), .wrst_n(rst_n), .wincr_i(write_en),
            .r2wptr_sync_i(r2wptr),

            .fifo_waddr_o(waddr),
            .wptr_o(wptr),
            .wfull_o(full)
        );
    // Read pointer controller
    rptr_ctrl #(ADDR_LEN)
        rptr_hndl(
        .rclk(rclk), .rrst_n(rst_n), .rincr_i(read_en),
        .w2rptr_sync_i(w2rptr),

        .fifo_raddr_o(raddr),
        .rptr_o(rptr),
        .rempty_o(empty)
        );

endmodule
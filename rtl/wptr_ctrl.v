
module wptr_ctrl #(ADDR_LEN  = 8)
    (
    input                        wclk, wrst_n, wincr_i,
    input      [ADDR_LEN   : 0]  r2wptr_sync_i,

    output     [ADDR_LEN-1 : 0]  fifo_waddr_o,
    output reg [ADDR_LEN   : 0]  wptr_o,
    output reg                   wfull_o);

    // Internal signals
    reg  [ADDR_LEN  : 0]    fifo_waddr;
    wire [ADDR_LEN : 0]     fifo_waddr_cnt, wptr_gray_next, r2wptr_bin;
    wire                    wfull;

    /***************************************************
    ********* fifo_waddr_o: Counter to inc the fifo memory address
    ****************************************************/

    always @(posedge wclk or negedge wrst_n) begin
        if(~wrst_n) fifo_waddr <= 0;
        else fifo_waddr <= fifo_waddr_cnt;
    end

    assign fifo_waddr_cnt = fifo_waddr + (wincr_i & !wfull_o);

    assign fifo_waddr_o = fifo_waddr[ADDR_LEN-1:0] ;

    /***********************************************
    ********* wptr_o: Grayscale encoded write pointer
    ************************************************/

    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n)  wptr_o <= 0;
        else wptr_o <= wptr_gray_next;
    end

    assign wptr_gray_next = (fifo_waddr_cnt>>1) ^ fifo_waddr_cnt;

    /***********************************************
    ********* wfull_o: fifo full logic
    ************************************************/

    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) wfull_o <= 0;
        else wfull_o <= wfull;
    end

    // wfull asserted by comparing next gray scale write pointer and synchronized read pointer in write domain, using the following three conditions:
    /*
        1. The wptr and the synchronized rptr MSB's are not equal (because the wptr must have wrapped
        one more time than the rptr).
        2. The wptr and the synchronized rptr 2nd MSB's are not equal (because an inverted 2 nd MSB from 
        one pointer must be tested against the un-inverted 2 nd MSB from the other pointer, which is required if the
        MSB's are also inverses of each other.
        3. All other wptr and synchronized rptr bits must be equal.
        
        Reference: https://www.verilogpro.com/asynchronous-fifo-design/
    */
    assign wfull = (wptr_gray_next == {!r2wptr_sync_i[ADDR_LEN:ADDR_LEN-1],r2wptr_sync_i[ADDR_LEN-2:0]});
    

endmodule
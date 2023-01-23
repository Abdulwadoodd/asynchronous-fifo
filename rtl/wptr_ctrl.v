
module wptr_ctrl #(ADDR_LEN  = 8)
    (
    input                        wclk, wrst_n, wincr_i,
    input      [ADDR_LEN   : 0]  r2wptr_sync_i,

    output     [ADDR_LEN-1 : 0]  fifo_waddr_o,
    output reg [ADDR_LEN   : 0]  wptr_o,
    output reg                   wfull_o);

    // Internal signals
    reg  [ADDR_LEN  : 0]    fifo_waddr;
    wire [ADDR_LEN : 0]     fifo_waddr_cnt, bin2gs;
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
        else wptr_o <= bin2gs;
    end

    assign bin2gs = (fifo_waddr_cnt>>1) ^ fifo_waddr_cnt;

    /***********************************************
    ********* wfull_o: fifo full logic
    ************************************************/

    always @(posedge wclk or negedge wrst_n) begin
        if(!wrst_n) wfull_o <= 0;
        else wfull_o <= wfull;
    end

    assign wfull = (bin2gs == {!r2wptr_sync_i[ADDR_LEN:ADDR_LEN-1],r2wptr_sync_i[ADDR_LEN-2:0]});



endmodule
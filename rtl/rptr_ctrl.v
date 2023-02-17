
module rptr_ctrl #(parameter ADDR_LEN = 8)
    (
    input                       rclk, rrst_n, rincr_i,
    input      [ADDR_LEN : 0]   w2rptr_sync_i,

    output     [ADDR_LEN-1: 0]  fifo_raddr_o,
    output reg [ADDR_LEN  : 0]  rptr_o,
    output reg                  rempty_o);

    // Internal signals
    reg  [ADDR_LEN : 0]     fifo_raddr;
    wire [ADDR_LEN : 0]     fifo_raddr_cnt, rptr_gray_next, w2rptr_bin;
    wire                    rempty;

    /***************************************************
    ******* fifo_raddr_o: Counter to inc the fifo memory address
    ****************************************************/

    always @(posedge rclk or negedge rrst_n) begin
        if(~rrst_n) fifo_raddr <= 0;
        else fifo_raddr <= fifo_raddr_cnt;
    end

    assign fifo_raddr_cnt = fifo_raddr + (rincr_i & !rempty_o);

    assign fifo_raddr_o = fifo_raddr[ADDR_LEN-1 : 0];

    /***********************************************
    ******* rptr_o: Grayscale encoded read pointer
    ************************************************/

    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n)  rptr_o <= 0;
        else rptr_o <= rptr_gray_next;
    end

    assign rptr_gray_next = (fifo_raddr_cnt>>1) ^ fifo_raddr_cnt;

    /***********************************************
    ******* rempty_o: fifo empty logic
    ************************************************/

    always @(posedge rclk or negedge rrst_n) begin
        if(!rrst_n) rempty_o <= 1;
        else rempty_o <= rempty;
    end
    // gray scale to binary decoder
    genvar i;
    generate
        for (i=0; i<=ADDR_LEN; i=i+1) begin
            assign w2rptr_bin[i] = ^ w2rptr_sync_i[ADDR_LEN : i];
        end
    endgenerate

    assign rempty = (w2rptr_bin == fifo_raddr_cnt);

    // wempty asserted by comparing next gray scale read pointer and synchronized write pointer in read domain.
    // assign rempty = (rptr_gray_next == w2rptr_sync_i);

    
endmodule
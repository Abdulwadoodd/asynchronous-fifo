
module fifo_mem #(ADDR_LEN = 8,
                 DATA_LEN = 32)
    (
    input wclk, wen_i,
    input [ADDR_LEN-1 : 0] waddr, raddr,
    input [DATA_LEN-1 : 0] wdata, 
    output [DATA_LEN-1 : 0] rdata);

    localparam DEPTH = 1<<ADDR_LEN;
    reg [DATA_LEN-1:0] dp_mem [0:DEPTH-1];

    always @(posedge wclk ) begin
        if(wen_i) dp_mem[waddr] <= wdata;
    end

    assign rdata = dp_mem[raddr];
    
endmodule
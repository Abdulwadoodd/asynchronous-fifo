
module sync #(parameter ADDR_LEN = 8)
    (
    input       clk, rst_n,
    input       [ADDR_LEN : 0] sync_i,
    output reg  [ADDR_LEN : 0] sync_o );

    reg [ADDR_LEN : 0] sync_reg;

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) {sync_o,sync_reg} <= 0;
        else {sync_o,sync_reg} <= {sync_reg,sync_i};
    end
    
endmodule
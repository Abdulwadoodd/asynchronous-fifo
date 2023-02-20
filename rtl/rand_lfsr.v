module rand_lfsr #( parameter DATA_LEN = 8) 
    (
    input rst_n, clk,
    output reg valid,
    output reg [DATA_LEN-1 : 0] rnd_num);

    localparam ADDRESS = $clog2(DATA_LEN);

    reg [DATA_LEN-1 : 0] rnd;
    wire [DATA_LEN-1 : 0] rnd_next;
    reg [ADDRESS-1 : 0] cnt ;
    wire [ADDRESS-1 : 0] cnt_next;
    wire feeback;

    always @ (posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            rnd <= 'h81; //An LFSR cannot have an all 0 state, thus reset to 81
            cnt <= 0;
            rnd_num <= 0;
        end else begin
            rnd <= rnd_next;
            cnt <= (cnt==DATA_LEN-1) ? 0 : cnt_next;
            rnd_num <= (cnt==DATA_LEN-1) ? rnd : rnd_num;
        end
    end
    
    //assign feeback = rnd[31] ^ rnd[21] ^ rnd[1] ^ rnd[0]; // tapping is done for DATA_LEN = 32
    assign feeback = rnd[7] ^ rnd[5] ^ rnd[4] ^ rnd[3];     // tapping for DATA_LEN = 8

    assign rnd_next = {rnd[DATA_LEN-2 : 0], feeback};

    assign cnt_next = cnt + 1;

    //assign valid = (!cnt) & rst_n;
    always @ (posedge clk) begin
        valid <= (cnt==DATA_LEN-1) & rst_n;
    end
    
endmodule
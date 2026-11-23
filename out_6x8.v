module out_6x8 #(
    parameter integer STEP_CYCLES = 1000
)( 
    input             clk, 
    input             rst_n, 
    input   [55:0] scanvalue,
    output reg [2:0]  addr_out, 
    output reg [7:0]  data,
    output reg [3:0]  data2
); 

    wire [55:0] payload; 
    wire [7:0] payload2; 
    
    // 时钟分频，产生轮询节拍
    wire step_tick;
    generate
        if (STEP_CYCLES <= 1) begin : gen_no_div
            assign step_tick = 1'b1;
        end else begin : gen_div
            reg [31:0] div_cnt;
            always @(posedge clk or negedge rst_n) begin
                if (!rst_n)
                    div_cnt <= 32'd0;
                else if (div_cnt >= STEP_CYCLES - 1)
                    div_cnt <= 32'd0;
                else
                    div_cnt <= div_cnt + 32'd1;
            end
            assign step_tick = (div_cnt == STEP_CYCLES - 1);
        end
    endgenerate

    // 组别轮询计数器 (0 ~ 5)
    reg [2:0] sel_idx;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sel_idx <= 3'd0;
        end else if (step_tick) begin
            if (sel_idx >= 3'd5)
                sel_idx <= 3'd0;
            else
                sel_idx <= sel_idx + 3'd1;
        end
    end

    
    function [7:0] payload_row; 
        input [2:0] idx; 
        begin 
            case (idx) 
                3'd0: payload_row = payload[7:0]; 
                3'd1: payload_row = payload[15:8]; 
                3'd2: payload_row = payload[23:16]; 
                3'd3: payload_row = payload[31:24]; 
                3'd4: payload_row = payload[39:32]; 
                3'd5: payload_row = payload[47:40]; 
                default: payload_row = 8'h00; 
            endcase 
        end 
    endfunction 

    function [3:0] payload2_row; 
        input [2:0] idx; 
        begin 
            case (idx) 
                3'd1: payload2_row = {2'b00, payload2[1:0]}; // 20
                3'd4: payload2_row = {1'b0, payload2[4:2]};  // 50
                3'd5: payload2_row = {1'b0, payload2[7:5]};  // 60
                default: payload2_row = 4'h0; 
            endcase 
        end 
    endfunction 
    
    // 10
    assign payload[0]   = scanvalue[32];
    assign payload[1]   = scanvalue[33];
    assign payload[2]   = scanvalue[34];
    assign payload[3]   = scanvalue[35];
    assign payload[4]   = scanvalue[36];
    assign payload[5]   = scanvalue[37];
    assign payload[6]   = scanvalue[38];
    assign payload[7]   = scanvalue[39];
    
    // 20
    assign payload[8]   = scanvalue[0];
    assign payload[9]   = scanvalue[1];
    assign payload[10]  = scanvalue[2];
    assign payload[11]  = scanvalue[3];
    assign payload[12]  = scanvalue[5];
    assign payload[13]  = scanvalue[6];
    assign payload[14]  = scanvalue[7];
    assign payload[15]  = scanvalue[48];
    assign payload2[0] = scanvalue[40];
    assign payload2[1] = scanvalue[41];
    
    // 30
    assign payload[16]  = scanvalue[8];
    assign payload[17]  = scanvalue[9];
    assign payload[18]  = scanvalue[10];
    assign payload[19]  = scanvalue[11];
    assign payload[20]  = scanvalue[12];
    assign payload[21]  = scanvalue[13];
    assign payload[22]  = scanvalue[14];
    assign payload[23]  = scanvalue[4];
    
    // 40
    assign payload[24]  = scanvalue[20];
    assign payload[25]  = scanvalue[24];
    assign payload[26]  = scanvalue[28];
    assign payload[27]  = scanvalue[22];
    assign payload[28]  = scanvalue[26];
    assign payload[29]  = scanvalue[23];
    assign payload[30]  = scanvalue[27];
    assign payload[31]  = scanvalue[31];
    
    // 50
    assign payload[32]  = scanvalue[21];
    assign payload[33]  = scanvalue[25];
    assign payload[34]  = scanvalue[29];
    assign payload[35]  = scanvalue[30];
    assign payload[36]  = scanvalue[15];
    assign payload[37]  = scanvalue[19];
    assign payload[38]  = scanvalue[18];
    assign payload[39]  = scanvalue[17];
    assign payload2[2] = scanvalue[49];
    assign payload2[3] = scanvalue[50];
    assign payload2[4] = scanvalue[51];
    
    // 60
    assign payload[40]  = scanvalue[16];
    assign payload[41]  = 1'b0;
    assign payload[42]  = 1'b0;
    assign payload[43]  = scanvalue[43];
    assign payload[44]  = scanvalue[44];
    assign payload[45]  = scanvalue[45];
    assign payload[46]  = scanvalue[46];
    assign payload[47]  = 1'b0;
    assign payload2[5] = scanvalue[52];
    assign payload2[6] = scanvalue[53];
    assign payload2[7] = scanvalue[54];
    
    always @(posedge clk or negedge rst_n) begin 
        if (!rst_n) begin 
            addr_out        <= 3'b000; 
            data            <= 8'h00; 
            data2           <= 4'h0;
        end else if (step_tick) begin 
            addr_out  <= sel_idx + 3'd1; // 1 to 6
            data      <= ~payload_row(sel_idx); 
            data2     <= ~payload2_row(sel_idx);
        end 
    end 

endmodule
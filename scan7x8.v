module scan7x8 #(
    parameter integer STEP_CYCLES = 1
) (
    input clk,
    input rst_n,
    output reg [6:0] addr,
    input [7:0] data_in,
    output reg [55:0] data_all,
    output reg frame_valid
);

    wire step_tick;

    generate
        if (STEP_CYCLES == 1) begin : gen_no_div
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

    reg [2:0] row_idx;

    // Scan address generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            row_idx <= 3'd0;
            addr <= 7'b1111110;
        end else if (step_tick) begin
            if (row_idx == 3'd6) begin
                row_idx <= 3'd0;
                addr <= 7'b1111110;
            end else begin
                row_idx <= row_idx + 3'd1;
                addr <= ~(7'b1 << (row_idx + 3'd1));
            end
        end
    end

    reg [55:0] buffer;

    // Data capture
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            buffer <= 56'd0;
            data_all <= 56'd0;
            frame_valid <= 1'b0;
        end else begin
            frame_valid <= 1'b0;
            if (step_tick) begin
                case (row_idx)
                    3'd0: buffer[7:0]   <= data_in;
                    3'd1: buffer[15:8]  <= data_in;
                    3'd2: buffer[23:16] <= data_in;
                    3'd3: buffer[31:24] <= data_in;
                    3'd4: buffer[39:32] <= data_in;
                    3'd5: buffer[47:40] <= data_in;
                    3'd6: begin
                        buffer[55:48] <= data_in;
                        data_all <= {data_in, buffer[47:0]};
                        frame_valid <= 1'b1;
                    end
                    default: ;
                endcase
            end
        end
    end

endmodule

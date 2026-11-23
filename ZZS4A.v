// ZZS4A 顶层模块
// 负责集成 out_6x8 和 scan7x8 模块，处理上电复位，
// 提供时钟，并实现上电初始化序列和输出覆盖。
module ZZS4A (
    output led0,
    output led1,
    output led2,
    output led3,
    output led4,
    output led5,
    output led6,
    output led7,
    output led8,
    output led9,
    output led10,
    output led11,
    output led12,
    output led13,
    output led14,
    output led15,
    output led16,
    output led17,
    output led18,
    output led19,
    output led20,
    output led21,
    output led22,
    output led23,
    output led24,
    output led25,
    output led26,
    output led27,
    output led28,
    output led29,
    output led30,
    output led31,
    output led32,
    output led33,
    output led34,
    output led35,
    output led36,
    output led37,
    output led38,
    output led39,
    output led40,
    output led41,
    output [6:0] scan_row_out,
    input [7:0] scan_col_in,
    
    // out_6x8 模块的输出接口，用于连接外部引脚
    output [2:0] addr_out,    // 地址输出，指示当前扫描组
    output [7:0] data_out,    // 数据输出
    output [3:0] data2_out,   // 辅助数据输出
    output out22f             // 额外控制信号
);

    wire osc_sig;
    wire oscena_sig;
    // 内部振荡器使能信号，始终使能
    assign oscena_sig = 1'b1;

    // 实例化内部振荡器模块
    // MAX II 器件通常提供内部振荡器，频率范围在 3.3MHz 到 5.56MHz 之间，典型值为 5.56MHz。
    osc osc_inst (
        .oscena (oscena_sig), // 振荡器使能
        .osc (osc_sig)        // 振荡器输出时钟信号
    );

    reg [15:0] por_cnt = 16'd0; // 上电复位计数器
    reg rst_n = 1'b0;             // 复位信号，低电平有效

    // 上电复位逻辑
    // 在时钟 osc_sig 的上升沿触发
    // 计数器 por_cnt 达到一定值后，将 rst_n 拉高，解除复位。
    // 16'hFFFE 确保在系统稳定后才解除复位。
    always @(posedge osc_sig) begin
        if (!rst_n) begin
            por_cnt <= por_cnt + 16'd1;
            if (por_cnt == 16'hFFFE) // 计数到 0xFFFE 个时钟周期后解除复位
                rst_n <= 1'b1;
        end
    end

    wire [6:0] scan_addr;       // 扫描地址输出
    wire [55:0] scan_data_all;  // 56位扫描数据总线
    wire frame_valid;           // 帧有效信号
    wire [7:0] scan_data_in;    // 扫描列输入数据

    assign scan_data_in = scan_col_in; // 将外部列输入连接到 scan_data_in
    assign scan_row_out = scan_addr;   // 将扫描地址连接到行输出

    // 实例化 scan7x8 模块
    // 负责矩阵扫描逻辑，将输入的 scan_col_in 数据按行扫描并输出到 scan_data_all
    // STEP_CYCLES 参数控制扫描速度，这里设置为 1000 个时钟周期。
    scan7x8 #(
        .STEP_CYCLES(16'd1000) // 扫描步进周期
    ) u_scan7x8 (
        .clk (osc_sig),         // 时钟
        .rst_n (rst_n),         // 复位信号
        .addr (scan_addr),      // 扫描地址输出
        .data_in (scan_data_in),// 扫描列输入数据
        .data_all (scan_data_all),// 56位扫描数据总线
        .frame_valid (frame_valid) // 帧有效信号
    );

    // 将 scan_data_all 的每一位连接到顶层 LED 输出
    assign led0 = scan_data_all[0];
    assign led1 = scan_data_all[1];
    assign led2 = scan_data_all[2];
    assign led3 = scan_data_all[3];
    assign led4 = scan_data_all[4];
    assign led5 = scan_data_all[5];
    assign led6 = scan_data_all[6];
    assign led7 = scan_data_all[7];
    assign led8 = scan_data_all[8];
    assign led9 = scan_data_all[9];
    assign led10 = scan_data_all[10];
    assign led11 = scan_data_all[11];
    assign led12 = scan_data_all[12];
    assign led13 = scan_data_all[13];
    assign led14 = scan_data_all[14];
    assign led15 = scan_data_all[15];
    assign led16 = scan_data_all[16];
    assign led17 = scan_data_all[17];
    assign led18 = scan_data_all[18];
    assign led19 = scan_data_all[19];
    assign led20 = scan_data_all[20];
    assign led21 = scan_data_all[21];
    assign led22 = scan_data_all[22];
    assign led23 = scan_data_all[23];
    assign led24 = scan_data_all[24];
    assign led25 = scan_data_all[25];
    assign led26 = scan_data_all[26];
    assign led27 = scan_data_all[27];
    assign led28 = scan_data_all[28];
    assign led29 = scan_data_all[29];
    assign led30 = scan_data_all[30];
    assign led31 = scan_data_all[31];
    assign led32 = scan_data_all[32];

    wire [2:0] out6x8_addr;  // out_6x8 模块内部的地址输出
    wire [3:0] out6x8_data2; // out_6x8 模块内部的辅助数据输出

    // 实例化 out_6x8 模块
    // 该模块负责处理扫描数据，并根据内部计数器自动循环输出 addr_out 和 data2_out。
    // STEP_CYCLES 参数控制 addr_out 的变化速度，用户要求大约 1 秒变化一次。
    // MAX II 内部振荡器典型频率约为 5.56 MHz。
    // 1 秒所需的周期数约为 5,560,000。
    out_6x8 #(
        .STEP_CYCLES(32'd5560000) // 步进周期，控制 addr_out 变化速度
    ) u_out_6x8 (
        .clk           (osc_sig),       // 时钟
        .rst_n         (rst_n),         // 复位信号
        .scanvalue     (scan_data_all), // 扫描数据输入
        .addr_out      (out6x8_addr),   // 模块内部地址输出
        .data          (data_out),      // 数据输出 (直接连接到顶层)
        .data2         (out6x8_data2)   // 模块内部辅助数据输出
    );

    // 上电初始化序列定时器和状态机
    // 用户要求上电后先输出特定值 0.5 秒，再输出另一特定值 0.5 秒，然后才进入正常工作模式。
    // 0.5 秒约等于 2,780,000 个时钟周期 (基于 5.56MHz 振荡器)。
    // 1.0 秒约等于 5,560,000 个时钟周期。
    reg [31:0] init_timer;      // 初始化定时器
    reg [1:0] init_state;       // 初始化状态机
                                // 0: 0 ~ 0.5s (输出 13)
                                // 1: 0.5s ~ 1.0s (输出 14)
                                // 2: 正常工作模式

    always @(posedge osc_sig) begin
        if (!rst_n) begin
            init_timer <= 32'd0; // 复位时清零定时器
            init_state <= 2'd0;  // 复位时进入初始状态 0
        end else begin
            if (init_state < 2'd2) begin // 仅在初始化阶段计时
                init_timer <= init_timer + 32'd1;
                if (init_timer == 32'd2780000 - 1) begin // 0.5 秒后进入状态 1
                    init_state <= 2'd1;
                end else if (init_timer == 32'd5560000 - 1) begin // 1.0 秒后进入正常工作状态 2
                    init_state <= 2'd2;
                end
            end
        end
    end

    reg out22f_reg;      // out22f 信号的寄存器
    reg [2:0] addr_out_reg;  // addr_out 信号的寄存器
    reg [3:0] data2_out_reg; // data2_out 信号的寄存器

    // 输出赋值逻辑
    // 在初始化阶段，强制输出特定的 8 位值 (out22f, addr_out, data2_out)。
    // 8 位顺序为 {out22f, addr_out, data2_out}。
    // 初始化结束后，恢复 out_6x8 模块的正常输出。
    always @(*) begin
        if (init_state == 2'd0) begin
            // 0 ~ 0.5s: 强制输出二进制 13 (8'd13 = 8'b0000_1101)
            // 对应 {out22f_reg, addr_out_reg, data2_out_reg} = {0, 000, 1101}
            {out22f_reg, addr_out_reg, data2_out_reg} = 8'b0000_1101;
        end else if (init_state == 2'd1) begin
            // 0.5s ~ 1.0s: 强制输出二进制 14 (8'd14 = 8'b0000_1110)
            // 对应 {out22f_reg, addr_out_reg, data2_out_reg} = {0, 000, 1110}
            {out22f_reg, addr_out_reg, data2_out_reg} = 8'b0000_1110;
        end else begin
            // 正常工作模式 (> 1.0s)
            out22f_reg = 1'b1;
            addr_out_reg = out6x8_addr;
            data2_out_reg = out6x8_data2;
        end
    end

    // 将内部寄存器连接到顶层输出端口
    assign out22f = out22f_reg;
    assign addr_out = addr_out_reg;
    assign data2_out = data2_out_reg;

endmodule

module top;
    // 定义矩阵尺寸和数据宽度
    localparam M = 4;
    localparam N = 3;
    localparam P = 5;
    localparam DATA_WIDTH = 16;      // 包含符号位的总位宽
    localparam FRACT_WIDTH = 8;      // 小数位数

    // 输入矩阵
    reg [M*N*DATA_WIDTH-1:0] a;
    reg [N*P*DATA_WIDTH-1:0] b;

    // 输出矩阵
    wire [M*P*DATA_WIDTH-1:0] y;


    // 实例化矩阵乘法器
    matrix_multiplier #(
        .M(M),
        .N(N),
        .P(P),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) uut (
        .a(a),
        .b(b),
        .y(y)
    );

    integer i, j;

    // 任务：显示矩阵
    task display_matrix;
        input [M*P*DATA_WIDTH-1:0] matrix;
        integer row, col;
        real value; // 使用 real 类型来存储浮点数值
        begin
            for (row = 0; row < M; row = row + 1) begin
                for (col = 0; col < P; col = col + 1) begin
                    // 提取每个输出元素，并以有符号十进制显示
                     // 提取每个输出元素的固定点数值
                        value = $signed(matrix[row*P*DATA_WIDTH + col*DATA_WIDTH +: DATA_WIDTH]);
                        // 将固定点数值转换为浮点数
                        value = value / (2.0 ** FRACT_WIDTH);
                        // 以浮点数形式显示
                        $write("%0.2f\t", value);
                end
                $write("\n");
            end
        end
    endtask
    task display_matrix_b;
        input [N*P*DATA_WIDTH-1:0] matrix_b;
        integer row, col;
        real value; // 使用 real 类型来存储浮点数值
        begin
            $display("矩阵 B:");
            for (row = 0; row < N; row = row + 1) begin
                for (col = 0; col < P; col = col + 1) begin
                    // 提取每个元素的固定点数值
                    value = $signed(matrix_b[(row*P + col)*DATA_WIDTH +: DATA_WIDTH]);
                    // 将固定点数值转换为浮点数
                    value = value / (2.0 ** FRACT_WIDTH);
                    // 以浮点数形式显示
                    $write("%0.2f\t", value);
                end
                $write("\n");
            end
        end
    endtask
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top);
    end
    initial begin
        // 测试用例 1：全 1 填充（正数）
        a = { M*N*DATA_WIDTH {1'b0} };
        for (i = 0; i < M*N; i = i + 1) begin
            a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd1 <<< FRACT_WIDTH; // 每个元素为 +1.0
        end
        b = { N*P*DATA_WIDTH {1'b0} };
        for (i = 0; i < N*P; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = 16'd1 <<< FRACT_WIDTH; // 每个元素为 +1.0
        end
        #10;
        $display("测试用例 1：全 1 填充（正数）");
        $display(b);
        display_matrix_b(b);
        display_matrix(y);

        // 测试用例 2：矩阵 A 包含负数
        for (i = 0; i < M*N; i = i + 1) begin
            if (i % 2)
                a[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd2 <<< FRACT_WIDTH; // 奇数元素为 -2.0
            else
                a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd3 <<< FRACT_WIDTH;  // 偶数元素为 +3.0
        end
        // 矩阵 B 仍为全 1
        #10;
        $display("测试用例 2：矩阵 A 包含负数");
        display_matrix_b(b);
        display_matrix(y);

        // 测试用例 3：矩阵 B 包含负数
        for (i = 0; i < N*P; i = i + 1) begin
            if (i % 3)
                b[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd1 <<< FRACT_WIDTH; // 每三个元素中一个为 -1.0
            else
                b[i*DATA_WIDTH +: DATA_WIDTH] = 16'd4 <<< FRACT_WIDTH;  // 其他元素为 +4.0
        end
        #10;
        $display("测试用例 3：矩阵 B 包含负数");
        display_matrix_b(b);
        display_matrix(y);

        // 测试用例 4：矩阵 A 和 B 都包含负数
        for (i = 0; i < M*N; i = i + 1) begin
            a[i*DATA_WIDTH +: DATA_WIDTH] = (i < 6) ? (-16'sd1 <<< FRACT_WIDTH) : (16'd2 <<< FRACT_WIDTH); // 前6元素为 -1.0，后面为 +2.0
        end
        for (i = 0; i < N*P; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = (i < 4) ? (16'd3 <<< FRACT_WIDTH) : (-16'sd2 <<< FRACT_WIDTH); // 前4元素为 +3.0，后面为 -2.0
        end
        #10;
        $display("测试用例 4：矩阵 A 和 B 都包含负数");
        display_matrix_b(b);
        display_matrix(y);

        a = { M*N*DATA_WIDTH {1'b0} };
        for (i = 0; i < M*N; i = i + 1) begin
            a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd2 ; // 每个元素为 +1.0
        end
        b = { N*P*DATA_WIDTH {1'b0} };
        for (i = 0; i < N*P; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd0 ; // 每个元素为 +1.0
        end
        #10;
        $display("测试用例 1：全 1 填充（正数）");
        $display(b);
        display_matrix_b(b);
        display_matrix(y);
        // 结束模拟
        $finish;
    end
endmodule

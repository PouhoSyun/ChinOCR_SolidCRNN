module top;
    // 定义矩阵尺寸和数据宽度
    localparam M = 4;
    localparam N = 3;
    localparam DATA_WIDTH = 16;      // 包含符号位的总位宽
    localparam FRACT_WIDTH = 8;      // 小数位数

    // 输入矩阵
    reg [M*N*DATA_WIDTH-1:0] a;
    reg [M*N*DATA_WIDTH-1:0] b;

    // 输出矩阵
    wire [M*N*DATA_WIDTH-1:0] y;


    // 实例化矩阵乘法器
    matrix_odoter #(
        .H(M),
        .W(N),
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
        input [M*N*DATA_WIDTH-1:0] matrix;
        integer row, col;
        real value; // 使用 real 类型来存储浮点数值
        begin
            for (row = 0; row < M; row = row + 1) begin
                for (col = 0; col < N; col = col + 1) begin
                    // 提取每个输出元素，并以有符号十进制显示
                     // 提取每个输出元素的固定点数值
                        value = $signed(matrix[row*N*DATA_WIDTH + col*DATA_WIDTH +: DATA_WIDTH]);
                        // 将固定点数值转换为浮点数
                        value = value / (2.0 ** FRACT_WIDTH);
                        // 以浮点数形式显示
                        $write("%0.8f\t", value);
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
            a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd1 <<< 6; // 每个元素为 0.25
        end
        b = { M*N*DATA_WIDTH {1'b0} };
        for (i = 0; i < M*N; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = 16'd1 <<< 6; // 每个元素为 0.25
        end
       
        #10;
        $display("测试用例 1：全 1 填充（正数）");
        display_matrix(a);
        $display("");
        display_matrix(b);
        $display("");
        display_matrix(y);

        // 测试用例 2：矩阵 A 包含负数
        for (i = 0; i < M*N; i = i + 1) begin
            if (i % 2)
                a[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd1 <<< 6; // 奇数元素为 -0.25
            else
                a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd3 <<< 6;  // 偶数元素为 0.75
        end
        // 矩阵 B 仍为全 1
        #10;
        $display("测试用例 2：矩阵 A 包含负数");
        display_matrix(a);
        $display("");
        display_matrix(b);
        $display("");
        display_matrix(y);

        // 测试用例 3：矩阵 B 包含负数
        for (i = 0; i < M*N; i = i + 1) begin
            if (i % 3)
                b[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd1 <<< 10; // 每三个元素中一个为 -0.25
            else
                b[i*DATA_WIDTH +: DATA_WIDTH] = 16'd4 <<< 10;  // 其他元素为 1
        end
        #10;
        $display("测试用例 2：矩阵 A 包含负数");
        display_matrix(a);
        $display("");
        display_matrix(b);
        $display("");
        display_matrix(y);

        // 测试用例 4：矩阵 A 和 B 都包含负数
        for (i = 0; i < M*N; i = i + 1) begin
            a[i*DATA_WIDTH +: DATA_WIDTH] = (i < 6) ? (-16'sd1 <<< 10) : (16'd2 <<< 10); // 前6元素为 -0.25，后面为 0.5
        end
        for (i = 0; i < M*N; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = (i < 4) ? (16'd3 <<< 10) : (-16'sd2 <<< 10); // 前4元素为 +0.75，后面为 -0.5
        end
        #10;
        $display("测试用例 4：矩阵 A 和 B 都包含负数");
        display_matrix(a);
        $display("");
        display_matrix(b);
        $display("");
        display_matrix(y);

        a = { M*N*DATA_WIDTH {1'b0} };
        for (i = 0; i < M*N; i = i + 1) begin
            a[i*DATA_WIDTH +: DATA_WIDTH] = 16'd2 ; // 每个元素为 +1.0
        end
        b = { M*N*DATA_WIDTH {1'b0} };
        for (i = 0; i < M*N; i = i + 1) begin
            b[i*DATA_WIDTH +: DATA_WIDTH] = -16'sd0 ; // 每个元素为 +1.0
        end
        #10;
        $display("测试用例 1：全 1 填充（正数）");
        display_matrix(a);
        $display("");
        display_matrix(b);
        $display("");
        display_matrix(y);
        // 结束模拟
        $finish;
    end
endmodule

module top;
    // 定义矩阵尺寸和数据宽度
    localparam M = 2;
    localparam N = 4;
    localparam DATA_WIDTH = 16;      // 包含符号位的总位宽
    localparam FRACT_WIDTH = 8;      // 小数位数



    reg [M*N*DATA_WIDTH-1:0] Wii;
    reg [M*M*DATA_WIDTH-1:0] Whi;
    reg [M*N*DATA_WIDTH-1:0] Wif;
    reg [M*M*DATA_WIDTH-1:0] Whf;
    reg [M*N*DATA_WIDTH-1:0] Wig;
    reg [M*M*DATA_WIDTH-1:0] Whg;
    reg [M*N*DATA_WIDTH-1:0] Wio;
    reg [M*M*DATA_WIDTH-1:0] Who;
    reg [M*DATA_WIDTH-1:0] bii;
    reg [M*DATA_WIDTH-1:0] bhi;
    reg [M*DATA_WIDTH-1:0] bif;
    reg [M*DATA_WIDTH-1:0] bhf;
    reg [M*DATA_WIDTH-1:0] big;
    reg [M*DATA_WIDTH-1:0] bhg;
    reg [M*DATA_WIDTH-1:0] bio;
    reg [M*DATA_WIDTH-1:0] bho;
    reg [M*DATA_WIDTH-1:0] ctI;
    reg [M*DATA_WIDTH-1:0] htI;
    reg [N*DATA_WIDTH-1:0] xt;

    // Outputs
    wire [M*DATA_WIDTH-1:0] ctO;
    wire [M*DATA_WIDTH-1:0] htO;

    // Instantiate the lstm module
    lstm #(
        .M(M),
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .FRACT_WIDTH(FRACT_WIDTH)
    ) lstm_inst (
        .Wii(Wii),
        .Whi(Whi),
        .Wif(Wif),
        .Whf(Whf),
        .Wig(Wig),
        .Whg(Whg),
        .Wio(Wio),
        .Who(Who),
        .bii(bii),
        .bhi(bhi),
        .bif(bif),
        .bhf(bhf),
        .big(big),
        .bhg(bhg),
        .bio(bio),
        .bho(bho),
        .ctI(ctI),
        .htI(htI),
        .xt(xt),
        .ctO(ctO),
        .htO(htO)
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
        for (i = 0; i < M*N; i = i + 1) begin
            if (i % 2) begin
                Wii[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Wif[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                Wig[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                Wio[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
            else begin
                Wii[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
                Wif[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Wig[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Wio[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
        end

        for (i = 0; i < 4; i = i + 1) begin
            if (i % 2)
                xt[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
            else
                xt[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
        end
        for (i = 0; i < 2; i = i + 1) begin
            if (i % 2) begin
                bii[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                bif[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                big[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                bio[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
                bhi[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                bhf[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                bhg[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                bho[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
            else begin
                bii[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
                bif[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                big[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                bio[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
                bhi[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                bhf[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                bhg[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                bho[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
        end
        for (i = 0; i < M*M; i = i + 1) begin
            if (i % 2) begin
                Whi[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Whf[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                Whg[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;// 奇数元素为 0
                Who[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
            else begin
                Whi[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
                Whf[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Whg[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
                Who[i*DATA_WIDTH +: DATA_WIDTH] = 'h0100;// 奇数元素为 1
            end
        end

        for (i = 0; i < 2; i = i + 1) begin
            if (i % 2)
                htI[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
            else
                htI[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
        end

        for (i = 0; i < 2; i = i + 1) begin
            if (i % 2)
                ctI[i*DATA_WIDTH +: DATA_WIDTH] = 'h0080;// 奇数元素为 0.5
            else
                ctI[i*DATA_WIDTH +: DATA_WIDTH] = 'h0000;  // 偶数元素为 0
        end
        #10;
        // 结束模拟
        $finish;
    end
endmodule

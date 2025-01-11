module test_divide;
    reg [7:0] a, b;  // 8位宽度
    wire [7:0] result;

    assign result = a / b;

    initial begin
        a = 20; // 被除数
        b = 6;  // 除数
        #10;    // 等待一段时间，输出结果
        $display("Result of %d / %d = %d", a, b, result);
    end
endmodule
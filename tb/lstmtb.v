`include "tb/lstm.v"
module top;
    
    // 定义矩阵尺寸和数据宽度
    parameter M = 256;  // hidden size 
    parameter N = 512;  //input size
    parameter totalcal = 41; //计算次数
    parameter DATA_WIDTH = 24;      // 包含符号位的总位宽
    parameter FRACT_WIDTH = 13;      // 小数位数
    //都是一行
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
    //41行
    reg [N*DATA_WIDTH-1:0] xt;

    // Outputs
    wire [M*DATA_WIDTH-1:0] c_t_out;
    wire [M*DATA_WIDTH-1:0] h_t_out;
    reg clk;

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
        .clk(clk),
        .c_t_out(c_t_out),
        .h_t_out(h_t_out)
    );

    integer i, j;
    assign htI = h_t_out;
    assign ctI = c_t_out;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top);
    end
    initial begin
        clk = 0;
        #5
        forever #5 clk = ~clk;  // 10单位时间一个时钟周期
    end
    
    //输入xt 
    integer r5;
    integer xt_file;
    integer ii;
    initial begin
        xt_file = $fopen("data_input/rnn_lstm0.txt","r");
        for(ii=0;ii<totalcal;ii=ii+1) begin
            r5 = $fscanf(xt_file,"%b\n",xt);
            #10;
            if(ii>0) begin
                $fdisplay(op_file1,"%b",c_t_out);
                $fdisplay(op_file2,"%b",h_t_out);
            end
        end
        #5
        $fdisplay(op_file1,"%b",c_t_out); 
        $fdisplay(op_file2,"%b",h_t_out); 
        #1000;
        $finish;
    end
    integer ct_output,ht_output;
    integer op_file1,op_file2;
    initial begin
        op_file1 = $fopen("tb/files/lstmtb_ct.txt", "w");
        if (op_file1 == 0) begin
                $display("Error: Unable to open file for index %0d", i);
                $finish;
        end
        op_file2 = $fopen("tb/files/lstmtb.txt", "w");
        if (op_file2 == 0) begin
                $display("Error: Unable to open file for index %0d", i);
                $finish;
        end
	end

    //w,b 读
    integer Wii_file,Wif_file,Wig_file,Wio_file,Whi_file,Whf_file,Whg_file,Who_file;
    integer bii_file,bif_file,big_file,bio_file,bhi_file,bhf_file,bhg_file,bho_file;
    integer r3;
    
    initial begin
        Wii_file = $fopen("model_para/rnn_0_weight_ii.txt","r");
        Wif_file = $fopen("model_para/rnn_0_weight_if.txt","r");
        Wig_file = $fopen("model_para/rnn_0_weight_ig.txt","r");
        Wio_file = $fopen("model_para/rnn_0_weight_io.txt","r");
        Whi_file = $fopen("model_para/rnn_0_weight_hi.txt","r");
        Whf_file = $fopen("model_para/rnn_0_weight_hf.txt","r");
        Whg_file = $fopen("model_para/rnn_0_weight_hg.txt","r");
        Who_file = $fopen("model_para/rnn_0_weight_ho.txt","r");
        r3 = $fscanf(Wii_file,"%b\n",Wii);
        r3 = $fscanf(Wif_file,"%b\n",Wif);
        r3 = $fscanf(Wig_file,"%b\n",Wig);
        r3 = $fscanf(Wio_file,"%b\n",Wio);
        r3 = $fscanf(Whi_file,"%b\n",Whi);
        r3 = $fscanf(Whf_file,"%b\n",Whf);
        r3 = $fscanf(Whg_file,"%b\n",Whg);
        r3 = $fscanf(Who_file,"%b\n",Who);
        bii_file = $fopen("model_para/rnn_0_bias_ii.txt","r");
        bif_file = $fopen("model_para/rnn_0_bias_if.txt","r");
        big_file = $fopen("model_para/rnn_0_bias_ig.txt","r");
        bio_file = $fopen("model_para/rnn_0_bias_io.txt","r");
        bhi_file = $fopen("model_para/rnn_0_bias_hi.txt","r");
        bhf_file = $fopen("model_para/rnn_0_bias_hf.txt","r");
        bhg_file = $fopen("model_para/rnn_0_bias_hg.txt","r");
        bho_file = $fopen("model_para/rnn_0_bias_ho.txt","r");
        r3 = $fscanf(bii_file,"%b\n",bii);
        r3 = $fscanf(bif_file,"%b\n",bif);
        r3 = $fscanf(big_file,"%b\n",big);
        r3 = $fscanf(bio_file,"%b\n",bio);
        r3 = $fscanf(bhi_file,"%b\n",bhi);
        r3 = $fscanf(bhf_file,"%b\n",bhf);
        r3 = $fscanf(bhg_file,"%b\n",bhg);
        r3 = $fscanf(bho_file,"%b\n",bho);

    end
endmodule

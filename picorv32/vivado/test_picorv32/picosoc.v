/*
 * pico片上系统
 * 
 * 使用picorv32连接各种存储器和设备
 * 存储器(mem)包括：sram(内部存储)，flash，外部存储
 *
 * 已有部件：
 * 1) picorv32 core 核心
 * 2) picosoc_mem internal_sram 内部存储器 
 *	占用地址：0x00000000 .. 0x00FFFFFF
 * 
 * 
 */
module picosoc ();

	//参数：传递给picorv32 和 picosoc_mem 
	parameter integer MEM_WORDS = 1024;
	parameter [31:0] STACKADDR = (4*MEM_WORDS);
	parameter [31:0] PROGADDR_RESET = 32'h00000000;

    reg clk;
    reg resetn;
	reg sram_ready;
	
	/*
	 * 连接picorv32和存储器
	 * 可以是内部存储器也可以是外部存储器
	 *
	 * notice: 先只使用内部存储器picosoc_mem
	 */
	wire mem_valid;
	wire mem_instr;
	wire mem_ready;
	wire [31:0] mem_addr;	//指定内存地址
	wire [31:0] mem_wdata;	//写入内存
	wire [3:0]  mem_wstrb;	//链接"写使能"，指定那些Byte被写
	wire [31:0] mem_rdata;	//存储器读取的数据(flash或者)
	
	wire [31:0] sram_rdata; //internal_sram读取的数据

	assign mem_rdata = sram_rdata;
	assign mem_ready = sram_ready;
	
	integer i;
	initial begin
		clk = 0;
        resetn = 0;
		$readmemh("/home/ckj/ckj_test/picorv32/new_asm_main.data",internal_sram.mem,0);
		
		for(i=0;i<13;i=i+1)
			$display("internal_sram.mem[%d] = %h",i,internal_sram.mem[i]);
	end
	
	always #5 clk=~clk;
	always #30 resetn=1;
	
	always @(posedge clk)
		sram_ready <= mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS;
		
    
	//1） picorv32 core
	picorv32 #(
		.STACKADDR(STACKADDR),				//x2堆栈指针的值
		.PROGADDR_RESET(PROGADDR_RESET),	//程序的开始地址
		.BARREL_SHIFTER(1),
		.ENABLE_IRQ(1),
		.ENABLE_IRQ_QREGS(0)
		) 
		cpu (
			.clk         (clk        ),		//input
			.resetn      (resetn     ),		//input
			.mem_valid   (mem_valid  ),		//output
			.mem_instr   (mem_instr  ),		//output
			.mem_ready   (mem_ready  ),		//input
			.mem_addr    (mem_addr   ),		//output
			.mem_wdata   (mem_wdata  ),		//output
			.mem_wstrb   (mem_wstrb  ),		//output
			.mem_rdata   (mem_rdata  )		//input
		);
		
	//2） picosoc_mem
	picosoc_mem #(.WORDS(MEM_WORDS)) internal_sram (
		.clk(clk),
		.wen((mem_valid && !mem_ready && mem_addr < 4*MEM_WORDS) ? mem_wstrb : 4'b0),
		.addr(mem_addr[23:2]),
		.wdata(mem_wdata),
		.rdata(sram_rdata)
	);
endmodule

/*
 * pico片上系统内存
 */
module picosoc_mem #(parameter integer WORDS = 1024)(
		input clk,
		input [3:0] wen,		//写使能
		input [21:0] addr,		//22位地址
		input [31:0] wdata, 	//32位写数据
		output reg [31:0] rdata	//32位读数据
	);
	//存储器 默认大小为1024*4B = 4KB
	reg [31:0] mem [0:WORDS-1];		

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule


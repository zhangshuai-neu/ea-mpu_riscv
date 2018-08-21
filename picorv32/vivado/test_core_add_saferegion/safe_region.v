`timescale 1ns / 1ps

/*
	定义safe region 模块
	功能：实现一个独立的安全存储区，能够进行多种操作
	
	操作种类:
		0)无操作
			op == 8'd0
			
		1)堆栈存储器操作(sm_op:stack mem operation)
			op == 8'd1	smpush	//wdata压入stack mem
			op == 8'd2	smpop	//stack mem读出，通过rdata传出
			
		2)扩展存储器操作
			实现新的mem
	
*/

module safe_region(
		input clk,
		input enop,					//操作使能
		input [7:0] op,				//操作
		input [31:0] wdata,			//写 数据
		output reg [31:0] rdata   	//读 数据
	);
	
	//操作
	parameter smpush=8'd1;
	parameter smpop=8'd2;
	
	//1)栈存储器
	parameter integer STACK_MEM_SIZE=256;			//默认大小为256*4B
	reg [31:0] stack_mem [0:STACK_MEM_SIZE-1];		//存储器
	reg [31:0] stack_index;		//索引
	
	initial begin
		stack_index = 32'h0;
	end

	always @(posedge clk) begin
		//smpush操作
		if (enop && op == smpush) begin
			stack_mem[stack_index] <= wdata;
			stack_index <= stack_index + 1;
		end
		//smpop操作
		if (enop && stack_index > 0 && op == smpop) begin
			rdata <= stack_mem[stack_index -1];
			stack_index <= stack_index - 1;
		end
	end

	//2)

endmodule

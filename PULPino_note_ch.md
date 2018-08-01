
PULPino 记录
==

A.读代码
--

**1.指令地址的流向**

	起始地址问题：
	zeroriscy_prefetch_buffer -> zeroriscy_if_stage -> zeroriscy_core ->
	core_region -> instruction_mem_wrap
	zeroriscy_prefetch_buffer 中的 fetch_addr 及其初始化过程，决定了程序的起始地址

	ram使能问题：
	instr_req_o 为1时才能使能ram

**2.时钟问题导致自动机不运转：**

	使能test_mode_i 打开所有部件的时钟

**3.指令的ram的处理**

	指令ram组成：
		instr_ram_wrap ->
			sp_ram_wrap -> sp_ram 		//当is_boot 为0时，使用该ram
			boot_rom_wrap -> boot_code	//当is_boot 为1时，使用boot_rom

**4.ram_mux的互斥访问问题**

	不同端口之间的冲突

**5.复位问题**

	复位信号：为0时，复位所有module
			为1时，正常开始执行

**6.中断**
	包含关系：
	pulpino_top -> peripherals_i -> apb_event_uint -> i_interrupt_unit

	中断使能信号：
		m_irq_enable:
		cs_registers -> core -> id_stage -> controller(id_stage) -> int_controller

		irq_req_ctrl_i:
		 -> id_stage ->controller(id_stage)

	外部中断中断信号的传递：irq_i / irq_to_core_int
	i_interrupt_unit -> apb_event_uint -> peripherals_i -> pulpino_top ->
	core_region -> id_stage -> int_controller

	中断使能：
	cs_registers模块下的m_irq_enable_o信号


B.Make编译过程
--

**makefile:**

	all:
		clk: xilinx_clock_manager
		mem: xilinx_mem_8192x32
		fp_fma: xilinx_fp_fma

		pulpino:
			make -C pulpino clean all => pulpino/pulpino.edf
			//批量操作 run.tcl脚本
			vivado -mode batch -source tcl/run.tcl

		pulpemu: make -C pulpemu clean all => pulpemu/pulpemu_top.bit


C.编译Xilinx工具链
--

**1.安装vivado 2015.1/2017.4**

**2.配置环境变量**

/opt/Xilinx_2015_1为我的安装目录，自己修改


	export LD_LIBRARY_PATH=/opt/Xilinx_2015_1/Vivado/2015.1/lib/lnx64.o
	PATH="/opt/Xilinx_2015_1/Vivado/2015.1/bin:/opt/Xilinx_2015_1/SDK/2015.1/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/lin/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/arm/lin/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/linux_toolchain/lin64_be/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/linux_toolchain/lin64_le/bin:/opt/Xilinx_2015_1/DocNav:${PATH}"

**3.工具链**

	git clone https://github.com/pulp-platform/ri5cy_gnu_toolchain
	make

**4.环境变量**

	自己修改目录
	PATH="/home/zhangshuai/develop/ri5cy_gnu_toolchain/install/bin:${PATH}"

**5.into pulpino/fpga/**

	可以先export USE_EXPORT_ZERO_RISCY=1，指定cpu
	make all
	pulpino/fpga/sw/sd_image下生成:
	BOOT.BIN devicetree.dtb fsbl.elf pulpemu_top.bit rootfs.tar u-boot.elf uImage

**6.拷贝进sd card**

	#为sd卡建立两个分区：
	boot(1分区) 和 root(2分区)
	将BOOT.BIN devicetree.dtb uImage拷贝进boot分区
	将rootfs.tar解压到root分区

**7.启动zedboard**

		启动zedboard，使用minicom进行连接，链接设备为 /dev/ttyACM0

		此时在zedboard中运行的是，zynq(Arm cortex-A9)及Linux-xlnx


D.测试PLUPino
--

**1.加载程序到PULPino**

目前，将程序加载到PULPino系统的唯一方法是通过SPI。 Linux使用其SPI主设备与PULPino
的SPI从设备通信，并直接写入PULPino的指令和数据存储器。可以在fpga/sw/apps/spiload
下找到的spiload程序可以解决这个问题。

	#在fpga/sw/apps/spiload目录下
	make

**2.使用scp拷贝新程序到zedboard**

	#在主机中安装 ssh
	sudo apt install openssh-server

	#修改ssh的配置文件 /etc/ssh/sshd_config

	设置sshd的配置文件的这条配置：PasswordAuthentication yes
	
	#注释掉这一行 PermitRootLogin without-password
	PermitRootLogin yes	#改为这一行

	service ssh restart

	在zedboard上添加新用户，修改/etc/shadow中该新用户的属性为
	leisl:1H9sF86SwXPkk:15695:5:99999:7:5:20000: 
	其中:15695:5:99999:7:5:20000:为修改内容

	#如何使用scp
	命令格式：scp -r local_folder remote_username@remote_ip:remote_folder  
	命令执行后需要输入用户密码

	例子：
	两台机器IP分别为：A.104.238.161.75，B.43.224.34.73。
	在A服务器上操作，将B服务器上/home/lk/目录下所有的文件全部复制到本地的/root目录下，
	命令为：scp -r root@43.224.34.73:/home/lk /root。



**3.编译在PULPino中运行的程序**

3.1 配置PULPIino risc-v编译器

	#环境变量：
	PATH="/home/zhangshuai/develop/ri5cy_gnu_toolchain/install/bin:${PATH}"

3.2 编译程序

	#在sw/目录下
	mkdir build
	cp cmake_configure.zeroriscy.gcc.sh ./build
	cd ./build

	#在build/下
	#修改cmake_configure.zeroriscy.gcc.sh 将 USE_ZERO_RISCY=1
	./cmake_configure.zeroriscy.gcc.sh
	cd ..

	#sw/下，编译所有程序
	make all

3.3 编译结果

	#在 sw/apps下，

**4.使用spiload向PULPino发送程序**

4.1 

sw/apps下的每个应用，在编译完成后会生成 slm_files/spi_stim.txt 文件
spi_stim.txt为该程序的16进制字符表示

4.2


E.开发流程
----

**1.PULPino的开发**

1.1 开发工具

	ModelSim：进行仿真 (10.2C之后版本)
	Vivado：创建PGA项目和bit流生成(Vivado 2015.1)
	u-boot：启动程序
	buildroot/linux-xlnx: 默认系统

1.2 主要目录

	ips: 外设代码及其接口，zero-riscy 和 riscv cpu代码
	rtl： PULPino 片上系统的代码，包括ram，axi接口，apb接口，外设接口
	fpga: xilinx的clock,memory和PULPino的vivado项目

1.3 开发流程

	ModelSim仿真
	使用Vivado Tcl进行项目管理
	生成bit文件和boot.bin
	编译u-boot buildroot linux-xlnx
	格式化sd card，将编译好的程序拷贝进sd card
	minicom进行串口测试

1.4 测试PULPino



**2.我们的步骤**

2.1 使用 vivado 进行仿真

	使用vivado(2017.4)进行仿真，vivado(2015) 有一些语法不支持
	github中的项目即为仿真的项目

2.2 修改和添加的文件

	Modified File：
	core_region.sv zeroriscy_core.sv zeroriscy_id_stage.sv

	New Added File：
	ea_mpu.sv ea_mpu_ram.sv data_ram_mux.sv (based on ram_mux.sv)

2.3 修改tcl将修改的内容加入项目

2.4 创建简单的app 和 串口测试

	测试EA-MPU在zedboard的运行情况

2.5 修改freeRTOS 和 串口测试

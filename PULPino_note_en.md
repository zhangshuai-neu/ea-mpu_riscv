
PULPino
====

A.Compiling ToolChain
--

**1.Intall vivado 2015.1/2017.4**

2015.1 is used to compile all project.

2017.4 is used to simulate the project, because they use system verilog, we
can't simulate the riscv core on 2015.1 directly.

**2.Configure Environment Variable**

/opt/Xilinx_2015_1 is my DIR，you need to modify

	export LD_LIBRARY_PATH=/opt/Xilinx_2015_1/Vivado/2015.1/lib/lnx64.o
	PATH="/opt/Xilinx_2015_1/Vivado/2015.1/bin:/opt/Xilinx_2015_1/SDK/2015.1/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/lin/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/arm/lin/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/linux_toolchain/lin64_be/bin:/opt/Xilinx_2015_1/SDK/2015.1/gnu/microblaze/linux_toolchain/lin64_le/bin:/opt/Xilinx_2015_1/DocNav:${PATH}"

**3.ToolChain**

	git clone https://github.com/pulp-platform/ri5cy_gnu_toolchain
	make

**4.Environment Variable**

	PATH="/home/zhangshuai/develop/ri5cy_gnu_toolchain/install/bin:${PATH}"

**5.into pulpino/fpga/**

	#set CPU
	export USE_ZERO_RISCY=1

	make all

	pulpino/fpga/sw/sd_image generate:
	BOOT.BIN devicetree.dtb fsbl.elf pulpemu_top.bit rootfs.tar u-boot.elf uImage

**6.Copy binary file into sd card**

B.Development
----

**1.PULPino's Development**

1.1 Development tools

	ModelSim: simulate (after 10.2C)
	Vivado： create FPGA proect and bit stream (vivado 2015.1)
	u-boot： boot program
	buildroot/linux-xlnx: default os

1.2 Critical Directory

	ips: peripheral and its inteface，zero-riscy and riscv cores code
	rtl： PULPino SoC，include ram，axi interface，apb interface，peripheral interface
	fpga: xilinx's clock, memory and PULPino's vivado project

1.3 Development Process

	ModelSim Simulation
	Use Vivado Tcl to manage FPGA project
	generate bit stream file and boot.bin
	build u-boot buildroot linux-xlnx
	copy the binary file into sd card
	Minicom serial port debugging

**2.Our Process**

2.1 Vivado Simulation

	We use vivado(2017.4) to simulate，and vivado(2015) have some unsupported grammer.
	The project in vivado is

2.2 Modify & Add Files

	Modified File：
	core_region.sv zeroriscy_core.sv zeroriscy_id_stage.sv

	New Added File：
	ea_mpu.sv ea_mpu_ram.sv data_ram_mux.sv (based on ram_mux.sv)

2.3 Modify Tcl

2.4 Create simple test APP

	test EA-MPU's running situation in Zedboard

2.5 Modify FreeRTOS

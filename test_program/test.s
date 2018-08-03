//用来测试risc-v的核心能否正常访存
li a5,0x1a0ff000
li a4,0x00000001
sw a4,0(a5)

li a5,0x00107e00
li a4,0x00008000
sw a4,0(a5)

li a5,0x00107e80
li a4,0x00008499
sw a4,0(a5)

li a5,0x00107f00
li a4,0x00100000
sw a4,0(a5)

li a5,0x00107f80
li a4,0x00100900
sw a4,0(a5)
		
li a5,0x00101000
li a4,0x08000001
sw a4,0(a5)

li a5,0x00107e80
lw a5,a4

li a5,0x00101008
sw a4,0(a5)




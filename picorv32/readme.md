### picorv32处理器

#### vivado项目

vivado/ 下提供了picorv32的测试vivado项目

    test_picorv32:为测试picorv32的项目，只提供了mem和cpu，和简单的risc-v代码

    test_core_add_saferegion：测试picorv32和相应的安全栈，简单的指令扩展
    对于picorv32的修改,都以注释//safe region开始

#!/usr/bin/expect -f

#设置环境变量以支持UTF-8
set env(LANG) "en_US.UTF-8"
send_user "\r============开始执行自动化脚本============\r"
spawn make run

# 设置超时时间（根据需要调整）
set timeout 240
set password [lindex $argv 0]

# 等待输入root密码和U-Boot提示符
expect {
   "password for chh: " {
        puts "\r============处理sudo密码和U-Boot命令============\r"
        send "$password\r"
        exp_continue
   }
   "=>" {
        # 在提示符下输入命令
        send "bootm 0x40400000 - 0x40000000\r"
   }
   timeout {
        exit 1
   }
}

puts "\n============测试启动hvisor, 同时测试是否可以启动virtio守护进程============\n"

expect {
    -re {job control turned off.*#} {
        send "bash\r"
    }
    timeout {
        exit 1
    }
}

expect {
    "root@(none):/# " {
        send "cd /home/arm64\r"
    }
    timeout {
        exit 1
    }
}

# 测试ls命令
expect {
    "root@(none):/home/arm64# " {
        send "ls > ./test/testresult/test_ls.txt\r"
    }
    timeout {
        exit 1
    }
}

# 测试pwd命令
expect {
    "root@(none):/home/arm64# " {
        send "pwd > ./test/testresult/test_pwd.txt\r"
    }
    timeout {
        exit 1
    }
}

# 测试装载内核模块
expect {
    "root@(none):/home/arm64# " {
        send "insmod hvisor.ko\r"
    }
    timeout {
        exit 1
    }
}
expect {
    "root@(none):/home/arm64# " {
        # send "dmesg | tail -n 2 | awk -F ']' '{print \$2}' > ./test/testresult/test_insmod.txt\r"
        send "./test/textract_dmesg.sh ./test/testresult/test_insmod.txt\r"
    }
    timeout {
        exit 1
    }
}


# 测试启动zone1
expect {
    "root@(none):/home/arm64# " {
        send "./linux2.sh\r"
    }
    timeout {
        exit 1
    }
}
expect {
    -re {Script started, file is /dev/null.*#} {
        send "bash\r"
    }
    timeout {
        exit 1
    }
}
expect {
    "root@(none):/home/arm64# " {
        # send "dmesg | tail -n 3 | awk -F ']' '{print \$2}' > ./test/testresult/test_zone1_start.txt\r"
        send "./test/textract_dmesg.sh ./test/testresult/test_zone1_start.txt\r"
    }
    timeout {
        exit 1
    }
}

# 测试是否可以screen进zone1
expect {
    "root@(none):/home/arm64# " {
        send "./screen_linux2.sh\r"
        send "\r"
    }
    timeout {
        exit 1
    }
}
expect {
   "# " {
      send "bash\r"
   }
    timeout {
        exit 1
    }
}
# 定义一个变量来存储zone1的ls命令的输出
set test_zone1_ls ""
expect "root@(none):/# "
send "cd /home/arm64\r"
expect "root@(none):/home/arm64# "
# 发送ls命令并捕获输出，在zone1中创建了一个zone1.txt，用来判断是否进入了zone1
send "ls | grep zone1.txt\r"
expect {
    -re {^[^\n]+\n(.*)\r\r\nroot@\(none\):/home/arm64# } {
        set test_zone1_ls $expect_out(1,string)
        send "\x01\x01d"
    }
    timeout {
        exit 1
    }
}
expect {
    "root@(none):/home/arm64# " {
        send "echo \"$test_zone1_ls\" > ./test/testresult/test_zone1_ls.txt\r"
    }
    timeout {
        exit 1
    }
}

# 测试打印启动zone1后的zone列表
expect {
    "root@(none):/home/arm64# " {
        send "./hvisor zone list > ./test/testresult/test_zone_list2.txt\r"
    }
    timeout {
        exit 1
    }
}

# 关闭zone1
expect {
    "root@(none):/home/arm64# " {
        send "./hvisor zone shutdown -id 1\r"
    }
    timeout {
        exit 1
    }
}

# 测试打印删除zone1后的zone列表
expect {
    "root@(none):/home/arm64# " {
        send "./hvisor zone list > ./test/testresult/test_zone_list1.txt\r"
    }
    timeout {
        exit 1
    }
}

# expect {
#     "root@(none):/home/arm64# " {
#         send "echo \"Test out finish!!\"\r"
#     }
#     timeout {
#         exit 1
#     }
# }

after 5000  # 延迟5秒
# 对比测试结果，最后打印
expect {
    "root@(none):/home/arm64# " {
        send "./test/tresult.sh\r"
    }
    timeout {
        exit 1
    }
}

expect {
    "Error: Test fail. Exiting script." {
        exit 1
    }
    "All tests passed. Script is exiting normally." {
        exit 0
    }
}

# 结束脚本保持交互状态
expect eof
exit 0

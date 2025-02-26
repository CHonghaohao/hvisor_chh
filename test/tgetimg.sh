#!/usr/bin/expect -f

# 设置环境变量以支持UTF-8
set env(LANG) "en_US.UTF-8"

send_user "\n============开始执行自动化脚本============\n"

# 连接ftp服务器，并监控该线程的输出
spawn ftp chhftp@localhost
# 设置超时时间（根据需要调整）
set timeout 1200
# 设置root密码
set password [lindex $argv 0]

# 输入sudo密码
# expect {
#    "password for chh:" {
#       send "$password\r"
#    }
# }

# 输入vsftpd服务器密码
expect {
   "Password:" {
      send "$password\r"
   }
}

expect {
   "ftp>" {
      send "get Image\r"
   }
}
# 获取ftp服务器的rootfs
expect {
   "ftp>" {
      send "get rootfs1.ext4\r"
   }
}

# 退出ftp
expect {
   "ftp>" {
      send "exit\r"
   }
}

# 结束脚本保持交互状态
# expect eof
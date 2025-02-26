#!/bin/bash

# 定义一个函数，用于处理dmesg输出
extract_dmesg() {
    local output_file="$1" # 函数的第一个参数是输出文件的路径

    # 获取dmesg的输出
    local dmesg_output=$(dmesg)

    # 使用awk处理输出
    echo "$dmesg_output" | awk '
    BEGIN {
        RS="\n"; # 设置记录分隔符为换行符
    }
    {
        # 去除每行开头的[]时间戳
        sub(/^\[[^]]*\] /, "")
        # 将处理过的行存储到数组lines中
        lines[NR] = $0
    }
    END {
        # 初始化计数器和输出数组
        count = 0
        output_lines[1] = ""
        output_lines[2] = ""
        # 从最后一行开始向前遍历
        for (i = NR; i > 0; i--) {
            if (lines[i] !~ /random: fast init done/) {
                # 如果当前行不包含"random: fast init done"
                if (count < 2) {
                    # 将该行存储到输出数组中
                    output_lines[2-count] = lines[i]
                    count++
                }
            }
            # 当count大于等于2时，跳出for循环
            if (count >= 2) {
                break
            }
        }
        # 按正确的顺序输出需要输出的行
        if (output_lines[1] != "") {
            printf "%s\n", output_lines[1]
        }
        if (output_lines[2] != "") {
            printf "%s\n", output_lines[2]
        }
    }
    ' > "$output_file"
}

# 调用函数，并传入输出文件的路径
extract_dmesg "$1"
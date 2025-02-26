#!/bin/bash

# set -x
# 定义两个数组，分别存储两个列表中的文件名
testcase_file_list=(
    ./test/testcase/tc_ls.txt
    ./test/testcase/tc_pwd.txt
    ./test/testcase/tc_insmod.txt
    ./test/testcase/tc_zone1_start.txt
    ./test/testcase/tc_zone1_ls.txt
    ./test/testcase/tc_zone_list2.txt
    ./test/testcase/tc_zone_list1.txt
)

testresult_file_list=(
    ./test/testresult/test_ls.txt
    ./test/testresult/test_pwd.txt
    ./test/testresult/test_insmod.txt
    ./test/testresult/test_zone1_start.txt
    ./test/testresult/test_zone1_ls.txt
    ./test/testresult/test_zone_list2.txt
    ./test/testresult/test_zone_list1.txt
)

testcase_name_list=(
    ls_out
    pwd_out
    insmod_hvisor.ko
    zone1_start_out
    screen_zone1
    zone1_start_list
    zone1_shutdown
)

# 获取文件列表的长度
testcase_file_list_len=${#testcase_file_list[@]}
testresult_file_list_len=${#testresult_file_list[@]}

# 检查两个列表的长度是否相等
if [ "$testcase_file_list_len" -ne "$testresult_file_list_len" ]; then
    echo "Error: The length of the two file lists is not equal."
    exit 1  # 返回错误状态码 1
fi

fail_count=0
# 循环遍历文件列表
for ((i = 0; i < testcase_file_list_len; i++)); do
    # 从列表中获取第i个文件名
    testcase_file=${testcase_file_list[i]}
    testresult_file=${testresult_file_list[i]}
    testcase_name=${testcase_name_list[i]}

    # 发送diff命令，并等待其执行完成
    diff "$testcase_file" "$testresult_file"
    exit_status=$?

    # 根据退出状态输出结果
    if [ "$exit_status" -eq 0 ]; then
        echo "$testcase_name $testresult_file PASS" >> ./test/result.txt
    else
        fail_count=$((fail_count+1))  # 增加fail_count的值
        echo "$testcase_name $testresult_file FAIL" >> ./test/result.txt
    fi
done


cat ./test/result.txt
# 格式化输出文件内容
printf "\n%-17s | %-40s | %s\n" "test name" "test result file" "result"
# 读取文件内容
while IFS= read -r line; do
    # 使用正则表达式提取测试用例名称和结果
    if [[ $line =~ ([^[:space:]]+)\ +(.*)\ +([A-Z]+)$ ]]; then
        testname=${BASH_REMATCH[1]}
        testcase=${BASH_REMATCH[2]}
        result=${BASH_REMATCH[3]}
        
        # 格式化输出
        printf "%-17s | %-40s | %s\n" "$testname" "$testcase" "$result"
    fi
done < "./test/result.txt"
printf "\n"

# 删除生成的文件
rm -v ./test/testresult/test_*.txt
rm -v ./test/result.txt

# 检查failcount是否大于0
if [ "$fail_count" -gt 0 ]; then
    echo "Error: Test fail. Exiting script."
    exit 1  # 异常退出，返回状态码1
else
    echo "All tests passed. Script is exiting normally."
    exit 0  # 正常退出，返回状态码0
fi
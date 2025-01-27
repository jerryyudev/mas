#!/bin/bash

# 提示用户输入IP地址或域名
read -p "请输入要扫描的IP地址或域名: " input

# 如果输入的是域名，使用nslookup转换为IP地址
if [[ $input =~ ^[a-zA-Z0-9.-]+$ ]]; then
    # 使用nslookup命令解析域名为IP地址
    ip_address=$(nslookup $input | grep 'Address' | tail -n 1 | awk '{ print $2 }')
    # 如果解析失败，输出错误信息
    if [ -z "$ip_address" ]; then
        echo "无法解析域名 $input，请检查域名是否正确。"
        exit 1
    fi
    echo "域名 $input 解析为 IP 地址 $ip_address"
else
    # 如果输入已经是IP地址，直接使用它
    ip_address=$input
fi

# 提示用户输入rate（扫描速率）
read -p "请输入扫描速率 (rate，单位: 包/秒): " rate

# 检查masscan是否已安装
if ! command -v masscan &> /dev/null
then
    echo "masscan 未安装，请先安装它。"
    exit 1
fi

# 持续扫描指定IP的所有端口
echo "开始扫描IP地址 $ip_address 的所有端口..."
while true; do
    masscan $ip_address -p1-65535 --rate $rate
done

#!/bin/bash

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
    echo "此脚本必须以root权限运行，请使用sudo执行或切换至root用户。"
    exit 1
fi

# 函数：检查是否为有效的IPv4地址
function is_valid_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        IFS='.' read -ra octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if [[ $octet -lt 0 || $octet -gt 255 ]]; then
                return 1
            fi
        done
        return 0
    fi
    return 1
}

# 提示用户输入IP地址或域名
read -p "请输入要扫描的IP地址或域名: " input

# 解析输入内容
if is_valid_ip "$input"; then
    ip_address="$input"
    echo "检测到有效IPv4地址: $ip_address"
else
    echo "正在解析域名 $input ..."
    # 使用dig获取IPv4地址（更可靠的解析方式）
    ip_address=$(dig +short A "$input" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' | head -n1)
    if [ -z "$ip_address" ]; then
        echo "无法解析域名 $input 的IPv4地址，请检查域名是否正确。"
        exit 1
    fi
    echo "域名解析成功: $input → $ip_address"
fi

# 获取扫描速率并验证
while true; do
    read -p "请输入扫描速率 (包/秒, 推荐1000-10000): " rate
    if [[ "$rate" =~ ^[0-9]+$ ]] && [ "$rate" -ge 100 ]; then
        break
    else
        echo "错误: 请输入大于100的整数。"
    fi
done

# 获取默认网络接口
interface=$(ip route | awk '/default/ {print $5; exit}')
if [ -z "$interface" ]; then
    echo "无法自动获取网络接口，请手动指定。"
    exit 1
fi

# 持续扫描循环
echo "开始扫描 [$ip_address] 所有端口"
echo "使用接口: $interface | 速率: $rate 包/秒"
echo "按 Ctrl+C 停止扫描"

while true; do
    echo "=== 扫描开始于: $(date +'%Y-%m-%d %H:%M:%S') ==="
    masscan -e "$interface" "$ip_address" -p1-65535 --rate "$rate" --wait 5
    echo "=== 扫描完成于: $(date +'%Y-%m-%d %H:%M:%S') ==="
    echo "等待10秒后重新扫描..."
    sleep 10
done

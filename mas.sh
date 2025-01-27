#!/bin/bash

# ======================
# 持续循环扫描脚本
# 版本: 6.0
# ======================

# 捕获中断信号
trap 'interrupt_handle' INT

interrupt_handle() {
    echo -e "\n\033[33m[!] 用户中断于: $(date +'%Y-%m-%d %H:%M:%S')\033[0m"
    [[ -n $masscan_pid ]] && kill -9 $masscan_pid 2>/dev/null
    exit 0
}

# 检查root权限
check_root() {
    [[ $EUID -ne 0 ]] && {
        echo -e "\033[31m[!] 需要特权权限 (使用 sudo 执行)\033[0m" >&2
        exit 1
    }
}

# 验证IP格式
validate_ip() {
    local ip_pattern='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    [[ $1 =~ $ip_pattern ]]
}

# 执行扫描（后台运行）
run_scan() {
    echo -e "\n\033[34m[+] 启动扫描 => IP: $1 | 速率: $2 包/秒\033[0m"
    masscan -e "$3" "$1" -p1-65535 --rate "$2" --norecover &
    masscan_pid=$!
    wait $masscan_pid  # 等待扫描完成或被中断
}

main() {
    check_root
    clear
    echo -e "\033[33m=== 持续循环扫描模式 ===\033[0m"

    # 获取目标
    while :; do
        read -p "输入目标地址 (IP/域名): " target
        [[ -n "$target" ]] && break
    done

    # 解析目标
    if validate_ip "$target"; then
        ip="$target"
    else
        echo -e "\033[36m[*] 解析域名: $target\033[0m"
        ip=$(dig +short A "$target" | grep -m1 -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$')
        [[ -z "$ip" ]] && {
            echo -e "\033[31m[!] 域名解析失败\033[0m"
            exit 1
        }
    fi

    # 获取速率
    while :; do
        read -p "输入扫描速率 (正整数): " rate
        [[ "$rate" =~ ^[1-9][0-9]*$ ]] && break
        echo -e "\033[31m[!] 请输入有效正整数\033[0m"
    done

    # 获取网络接口
    interface=$(ip route | awk '/default/{print $5; exit}')
    [[ -z "$interface" ]] && {
        echo -e "\033[31m[!] 网络接口获取失败\033[0m"
        exit 1
    }

    # 显示配置
    echo -e "\n\033[32m[ 扫描配置 ]"
    echo "目标IP: $ip"
    echo "网络接口: $interface"
    echo "扫描速率: $rate 包/秒"
    echo -e "启动时间: $(date +'%Y-%m-%d %H:%M:%S')\033[0m"

    # 持续扫描循环
    while :; do
        run_scan "$ip" "$rate" "$interface"
        echo -e "\n\033[35m[~] 等待10秒后重新扫描... (CTRL+C退出)\033[0m"
        
        # 带中断检测的等待
        for ((i=10; i>0; i--)); do
            printf "\r剩余等待时间: %2d 秒" $i
            sleep 1
        done
        echo
    done
}

main "$@"

# 一键运行代码:'curl -sSL https://raw.githubusercontent.com/jerryyudev/mas/main/mas.sh -o mas.sh && chmod +x mas.sh && ./mas.sh'
以下是该脚本所需的所有依赖工具和库的整理表格：

依赖名称 功能描述 Debian/Ubuntu 安装命令	CentOS/RHEL 安装命令	是否必需

masscan 高速端口扫描工具	sudo apt install masscan	sudo yum install masscan	是

dnsutils	提供 dig 命令（DNS解析）	sudo apt install dnsutils	sudo yum install bind-utils	是

iproute2	提供 ip 命令（网络接口管理）	sudo apt install iproute2	sudo yum install iproute	是

bc	数学计算工具（用于时间估算）	sudo apt install bc	sudo yum install bc	是

bash (4.0+ 版本)	脚本解释器环境	通常预装，无需额外安装	通常预装，无需额外安装	是




补充说明
运行环境要求：

Root 权限：必须使用 sudo 或以 root 用户运行（因 masscan 需要特权权限）。

Bash 版本：需 Bash 4.0+（现代 Linux 系统默认满足）。

推荐系统：

Debian/Ubuntu/Kali

CentOS/RHEL/Fedora

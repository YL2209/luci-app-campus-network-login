#!/bin/sh

# 获取UCI配置参数
CONFIG="campus_network.login"
USERNAME=$(uci -q get "$CONFIG.username") || USERNAME=""
PWD=$(uci -q get "$CONFIG.pwd") || PWD=""
WLANUSERIP=$(uci -q get "$CONFIG.wlanuserip") || WLANUSERIP=""
NASIP=$(uci -q get "$CONFIG.nasip") || NASIP=""
LOGIN_URL=$(uci -q get "$CONFIG.login_url") || LOGIN_URL=""
MAX_ATTEMPTS=$(uci -q get "$CONFIG.max_attempts") || MAX_ATTEMPTS=5
PING_IP=$(uci -q get "$CONFIG.ping_ip") || PING_IP="114.114.114.114"  # 默认回退

# 检查必要参数
if [ -z "$USERNAME" ] || [ -z "$PWD" ] || [ -z "$WLANUSERIP" ] || [ -z "$NASIP" ] || [ -z "$LOGIN_URL" ]; then
    echo "$(date): Configuration Error - Missing parameters!" >> /etc/xyw/log.txt
    exit 1
fi

# 构造登录数据
LOGIN_DATA="username=$USERNAME&pwd=$PWD&validCodeFlag=false&wlanuserip=$WLANUSERIP&nasip=$NASIP"
ATTEMPT=0

LOG="/etc/xyw/log.txt"
# 日志函数
log_to_system() {
    local level=$1
    local msg=$2
    # logger -t CampusLogin -p "user.$level" "$msg"
    # 可选：同时写入原日志文件
    echo "$(date "+%Y-%m-%d %H:%M:%S") [$level] $msg" >> "$LOG"
}

CURL_LOG="/etc/xyw/curl_log.txt"
# 执行 curl 并记录
attempt_login() {
    local url=$1
    local data=$2
    local output=$(curl -s -d "$LOGIN_DATA" "$LOGIN_URL")
    
    # 记录到文件
    echo "$output" > "$CURL_LOG"
    
    # 同时记录到系统日志
    log_to_system "notice" "CURL Output: $(cat "$CURL_LOG")"
    
    return $?
}

check_network() {
    ping -c 1 -W 3 "$PING_IP" > /dev/null 2>&1
    return $?
}

while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
    if check_network; then
        log_to_system info "网络连接成功"
        break
    else
        log_to_system notice "尝试【$((ATTEMPT+1))】登录..."
        attempt_login()
        sleep 10
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    log_to_system err "错误：已达到最大尝试次数！"
fi
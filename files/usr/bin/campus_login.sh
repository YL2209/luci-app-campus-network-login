#!/bin/sh

# 获取UCI配置参数
CONFIG="campus_network.login"
USERNAME=$(uci -q get "$CONFIG.username") || USERNAME=""
PWD=$(uci -q get "$CONFIG.pwd") || PWD=""
WLANUSERIP=$(uci -q get "$CONFIG.wlanuserip") || WLANUSERIP=""
NASIP=$(uci -q get "$CONFIG.nasip") || NASIP=""
LOGIN_URL=$(uci -q get "$CONFIG.login_url") || LOGIN_URL=""
MAX_ATTEMPTS=$(uci -q get "$CONFIG.max_attempts") || MAX_ATTEMPTS=5

# 检查必要参数
if [ -z "$USERNAME" ] || [ -z "$PWD" ] || [ -z "$WLANUSERIP" ] || [ -z "$NASIP" ] || [ -z "$LOGIN_URL" ]; then
    echo "$(date): Configuration Error - Missing parameters!" >> /etc/xyw/log.txt
    exit 1
fi

# 构造登录数据
LOGIN_DATA="username=$USERNAME&pwd=$PWD&validCodeFlag=false&wlanuserip=$WLANUSERIP&nasip=$NASIP"
ATTEMPT=0

# 创建日志目录
mkdir -p /etc/xyw

while [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; do
    if ping -c 1 114.114.114.114 >/dev/null 2>&1; then
        echo "$(date): Internet Connection OK" >> /etc/xyw/log.txt
        break
    else
        echo "$(date): Attempt $((ATTEMPT+1)) - Logging in..." >> /etc/xyw/log.txt
        curl -s -d "$LOGIN_DATA" -o /etc/xyw/curl_log.txt "$LOGIN_URL"
        sleep 10
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ "$ATTEMPT" -ge "$MAX_ATTEMPTS" ]; then
    echo "$(date): Error: Maximum attempts reached!" >> /etc/xyw/log.txt
fi
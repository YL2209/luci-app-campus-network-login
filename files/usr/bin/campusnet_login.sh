mkdir -p files/usr/bin
cat << 'EOF' > files/usr/bin/campusnet_login.sh
#!/bin/sh

# 从配置文件读取敏感信息，提高安全性
CONFIG_FILE="/etc/login_config.ini"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
    echo "Loaded config: USER=$USER, PWD=***, WLANUSERIP=$WLANUSERIP, NASIP=$NASIP, LOGIN_URL=$LOGIN_URL, PING_IP=$PING_IP, MAX_ATTEMPTS=$MAX_ATTEMPTS"
else
    logger -t "LoginScript" "Config file $CONFIG_FILE not found. Please create it with the required variables."
    exit 1
fi

# 登录网址（此为我校园网的网址）
LOGIN_URL=${LOGIN_URL:-"http://222.197.192.56:9090/zportal/login/do"}
# 最大尝试次数
MAX_ATTEMPTS=${MAX_ATTEMPTS:-5}
# 用于检查网络连接的IP
PING_IP=${PING_IP:-223.6.6.6}
ATTEMPT=0

# 构造登录数据
LOGIN_DATA="username=$USER&pwd=$PWD&validCodeFlag=false&wlanuserip=$WLANUSERIP&nasip=$NASIP"
echo "Login data: $LOGIN_DATA"

# 日志记录使用系统日志
log_message() {
    local message="$1"
    logger -t "LoginScript" "$message"
}

# 循环检查网络连接，直到连接成功或达到最大尝试次数
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    # 检查外部网络连接是否正常
    if ping -c 1 "$PING_IP" > /dev/null 2>&1; then
        log_message "Internet OK"
        echo "Internet OK"
        break
    else
        log_message "Internet connection failed. Attempt $((ATTEMPT + 1)) to log in."
        # 尝试登录并记录输出到系统日志
        CURL_OUTPUT=$(curl -s -d "$LOGIN_DATA" "$LOGIN_URL")
        CURL_STATUS=$?
        if [ $CURL_STATUS -ne 0 ]; then
            log_message "Curl request failed with status $CURL_STATUS"
        else
            # 这里可根据实际登录成功的标识进行判断
            if echo "$CURL_OUTPUT" | grep -q "success"; then
                log_message "Login successful"
                echo "Login successful"
                break
            fi
        fi
        log_message "Login attempt output: $CURL_OUTPUT"
        echo "Login attempt output: $CURL_OUTPUT"
        
        # 给服务器一些时间来建立连接
        sleep 10
        ATTEMPT=$((ATTEMPT + 1))
    fi
done

if [ $ATTEMPT -ge $MAX_ATTEMPTS ]; then
    log_message "Failed to connect to the Internet after $MAX_ATTEMPTS attempts."
    echo "Failed to connect to the Internet after $MAX_ATTEMPTS attempts."
fi
EOF
chmod +x files/usr/bin/campusnet_login.sh
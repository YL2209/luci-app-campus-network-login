require("luci.sys")

m = Map("campus_network", translate("Campus Network Login Settings"),
    translate('配置校园网络认证和调度的参数。<br /><br />详情请参考文档：<a href="https://blog.naokuo.top/p/522a17f8.html" target="_blank">点击查看文档</a>'));

s = m:section(TypedSection, "login", translate("Login Parameters"));
s.anonymous = true;

username = s:option(Value, "username", translate("Username"), translate('Usually for your student ID.'));
username.rmempty = false;

pwd = s:option(Value, "pwd", translate("Password"));
pwd.password = true;
pwd.rmempty = false;

wlanuserip = s:option(Value, "wlanuserip", translate("WLAN User IP"));
wlanuserip.rmempty = false;
wlanuserip.placeholder = "wlanuserip";

nasip = s:option(Value, "nasip", translate("Network Access Server IP"));
nasip.rmempty = false;
nasip.placeholder = "nasip";

url = s:option(Value, "login_url", translate("Login URL"));
url.rmempty = false;

ping = s:option(Value, "ping_ip", translate("Ping Test IP"), 
    translate("IP address for network connectivity detection (e.g. 114.114.114.114)"));
ping.datatype = "ip4addr";
ping.rmempty = false;

attempts = s:option(Value, "max_attempts", translate("Max Attempts"));
attempts.datatype = "uinteger";
attempts.rmempty = false;

-- Cron Schedule
s = m:section(TypedSection, "cron", translate("Automatic Logon"));
s.anonymous = true;
enabled = s:option(Flag, 'enabled', translate('Enable'), translate("Enable Cron Schedule"));
enabled.rmempty = false;
cron_schedule = s:option(Value, "cron_schedule", translate("Cron Schedule"), translate("Cron expression (e.g. '*/1 * * * *' for every 1 minutes)"))
cron_schedule.rmempty = false
    
function m.on_after_commit(self)
    local uci = require "luci.model.uci".cursor()
    local enabled = uci:get("campus_network", "cron", "enabled") or ""
    local cron_schedule = uci:get("campus_network", "cron", "cron_schedule") or ""
    local script_path = "/usr/libexec/campus_login >/dev/null 2>&1"

    -- 安全删除所有匹配脚本路径的旧任务（使用精确匹配）
    os.execute("crontab -l 2>/dev/null | grep -vF '"..script_path.."' | crontab -")

    -- 仅在启用状态时处理定时任务
    if enabled == "1" then

        -- 增强版cron格式验证（基础格式检查）
        if not cron_schedule:match("^[%d%-%*/%,]+ [%d%-%*/%,]+ [%d%-%*/%,]+ [%d%-%*/%,]+ [%d%-%*/%,]+$") then
            luci.http.redirect(luci.dispatcher.build_url("admin/services/campus_network"))
            return
        end

        -- 安全构造cron条目（防御命令注入）
        local function shell_escape(str)
            return "'"..str:gsub("'", "'\"'\"'").."'"
        end

        local cron_entry = string.format("%s %s", 
            shell_escape(cron_schedule),
            shell_escape(script_path)
        )

        -- 原子化更新crontab（使用临时文件避免竞态条件）
        os.execute("tempfile=$(mktemp) && crontab -l 2>/dev/null > $tempfile; echo "..cron_entry.." >> $tempfile; crontab $tempfile; rm -f $tempfile")
    end

    -- 重启cron服务
    os.execute("/etc/init.d/cron reload >/dev/null")
end

return m
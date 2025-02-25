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
cron_schedule = s:option(Value, "cron_schedule", translate("Cron Schedule"), translate("Cron expression (e.g. '*/1 * * * *' for every 1 minutes)"))
cron_schedule.rmempty = false

function m.on_after_commit(self)
    local uci = require "luci.model.uci".cursor()
    local cron_schedule = uci:get("campus_network", "login", "cron_schedule") or ""
    local script_path = "/usr/libexec/campus_login"

    -- 安全删除旧任务
    os.execute("crontab -l | grep -v '"..script_path.."' | crontab -")
    
    if cron_schedule ~= "" and cron_schedule ~= nil then
        -- 验证Cron表达式格式
        if not cron_schedule:match("%S+ %S+ %S+ %S+ %S+") then
            luci.http.redirect(luci.dispatcher.build_url("admin/services/campus_network"))
            return
        end
        
        -- 安全添加新任务
        os.execute("(crontab -l; echo '"..cron_schedule.." "..script_path.."') | crontab -")
        
        -- 重启cron服务
        os.execute("/etc/init.d/cron restart >/dev/null 2>&1")
    end
end

return m
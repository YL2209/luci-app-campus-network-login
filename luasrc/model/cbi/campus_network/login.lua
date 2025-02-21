m = Map("campus_network", translate("Campus Network Login Settings"),
    translate("Configure parameters for campus network authentication and scheduling."))

s = m:section(NamedSection, "login", "login", translate("Login Parameters"))
s.addremove = false

help_link = s:option(DummyValue, "help_link", translate("Documentation"))
help_link.rawhtml = true
help_link.value = '<a href="https://blog.naokuo.top/p/522a17f8.html" target="_blank">'..translate("Click to view documentation")..'</a>'
    
s:option(Value, "username", translate("Username")).rmempty = false
pass = s:option(Value, "pwd", translate("Password"))
pass.password = true
pass.rmempty = false
wlanuserip = s:option(Value, "wlanuserip", translate("WLAN User IP"))
wlanuserip.rmempty = false
wlanuserip.placeholder = "wlanuserip"
nasip = s:option(Value, "nasip", translate("NAS IP"))
nasip.rmempty = false
nasip.placeholder = "nasip"
s:option(Value, "login_url", translate("Login URL")).rmempty = false
ping_ip = s:option(Value, "ping_ip", translate("Ping Test IP"), translate("IP address for network connectivity detection (e.g. 114.114.114.114)"))
ping_ip.datatype = "ip4addr"  -- IP格式验证
ping_ip.rmempty = false       -- 必填项
s:option(Value, "max_attempts", translate("Max Attempts")).datatype = "uinteger"

-- Cron Schedule
cron = s:option(Value, "cron_schedule", translate("Cron Schedule"), translate("Cron expression (e.g. '*/1 * * * *' for every 1 minutes)"))
cron.rmempty = false

function m.on_after_commit(self)
    local uci = require "luci.model.uci".cursor()
    local cron_schedule = uci:get("campus_network", "login", "cron_schedule") or ""
    local script_path = "/usr/bin/campus_login.sh"

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
local m = Map("campus_network", translate("Campus Network Login Settings"),
    translate("Configure parameters for campus network authentication and scheduling."))

local s = m:section(NamedSection, "login", "login", translate("Login Parameters"))
s.addremove = false

s:option(Value, "username", translate("Username")).rmempty = false
s:option(Value, "pwd", translate("Password")).password = true
s:option(Value, "wlanuserip", translate("WLAN User IP")).rmempty = false
s:option(Value, "nasip", translate("NAS IP")).rmempty = false
s:option(Value, "login_url", translate("Login URL")).rmempty = false
s:option(Value, "max_attempts", translate("Max Attempts")).datatype = "uinteger"

-- Cron Schedule
local cron = s:option(Value, "cron_schedule", translate("Cron Schedule"),
    translate("Cron expression (e.g. '*/5 * * * *' for every 5 minutes)"))
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
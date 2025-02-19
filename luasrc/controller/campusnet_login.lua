mkdir -p luasrc/controller
cat << EOF > luasrc/controller/campusnet_login.lua
module("luci.controller.campusnet_login", package.seeall)

local validators = require "luci.validate"

function index()
    entry({"admin", "network", "campusnet_login"}, cbi("admin_network/campusnet_login"), _("Campus Network Login"), 90).dependent = false
end

function validate_input(user, pwd, wlanuserip, nasip, login_url, ping_ip, max_attempts)
    local errors = {}

    if not user or #user == 0 then
        table.insert(errors, "Username cannot be empty.")
    end
    if not pwd or #pwd == 0 then
        table.insert(errors, "Password cannot be empty.")
    end
    if not validators.IP4:validate(wlanuserip) then
        table.insert(errors, "Invalid WLAN User IP.")
    end
    if not validators.IP4:validate(nasip) then
        table.insert(errors, "Invalid NAS IP.")
    end
    if not validators.URL:validate(login_url) then
        table.insert(errors, "Invalid Login URL.")
    end
    if not validators.IP4:validate(ping_ip) then
        table.insert(errors, "Invalid Ping IP.")
    end
    if not tonumber(max_attempts) or tonumber(max_attempts) <= 0 then
        table.insert(errors, "Maximum attempts must be a positive integer.")
    end

    if #errors > 0 then
        return table.concat(errors, "<br/>")
    end

    return nil
end

function save_config()
    local user = luci.http.formvalue("user")
    local pwd = luci.http.formvalue("pwd")
    local wlanuserip = luci.http.formvalue("wlanuserip")
    local nasip = luci.http.formvalue("nasip")
    local login_url = luci.http.formvalue("login_url")
    local ping_ip = luci.http.formvalue("ping_ip")
    local max_attempts = luci.http.formvalue("max_attempts")

    local error_msg = validate_input(user, pwd, wlanuserip, nasip, login_url, ping_ip, max_attempts)
    if error_msg then
        luci.http.setcookie("error_msg", error_msg)
        luci.http.redirect(luci.dispatcher.build_url("admin", "network", "campusnet_login"))
        return
    end

    local uci = require "luci.model.uci".cursor()
    uci:set("login_config", "main", "user", user)
    uci:set("login_config", "main", "pwd", pwd)
    uci:set("login_config", "main", "wlanuserip", wlanuserip)
    uci:set("login_config", "main", "nasip", nasip)
    uci:set("login_config", "main", "login_url", login_url)
    uci:set("login_config", "main", "ping_ip", ping_ip)
    uci:set("login_config", "main", "max_attempts", max_attempts)
    uci:commit("login_config")

    local config_file = io.open("/etc/login_config.ini", "w")
    if config_file then
        config_file:write("USER="..user.."\n")
        config_file:write("PWD="..pwd.."\n")
        config_file:write("WLANUSERIP="..wlanuserip.."\n")
        config_file:write("NASIP="..nasip.."\n")
        config_file:write("LOGIN_URL="..login_url.."\n")
        config_file:write("PING_IP="..ping_ip.."\n")
        config_file:write("MAX_ATTEMPTS="..max_attempts.."\n")
        config_file:close()
    end

    luci.http.redirect(luci.dispatcher.build_url("admin", "network", "campusnet_login"))
end

if luci.http.formvalue("save_config") then
    save_config()
end
EOF
module("luci.controller.campus_network", package.seeall)

function index()
    -- 主入口点
    local page
    page = entry({"admin", "services", "campus_network"},
        alias("admin", "services", "campus_network", "login"), 
        _("Campus Network Login"), 60)
    page.dependent = true
    page.acl_depends = { "luci-app-campus-network-login" }

    -- 横向切换子菜单
    entry({"admin", "services", "campus_network", "login"},
        cbi("campus_network/login"), 
        _("Login Settings"), 61).leaf = true

    entry({"admin", "services", "campus_network", "logs"},
        template("campus_network/logs"),
        _("View Logs"), 62).leaf = true
end

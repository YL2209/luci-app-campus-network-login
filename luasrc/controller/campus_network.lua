module("luci.controller.campus_network", package.seeall)

function index()
    entry({"admin", "services", "campus_network"}, cbi("campus_network/login"), _("Campus Network Login"), 60)
end
require("luci.sys")

m = Map("campus_network", translate("Campus Network Login Settings"),
    translate('Configure parameters for campus network authentication and scheduling.<br /><br />Please refer to the document for details:<a href="https://blog.naokuo.top/p/522a17f8.html" target="_blank">Click to view document</a>'));

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


cron = m:section(TypedSection, "cron", translate("Plan tasks."))
cron.addremove = false
cron.anonymous = true

enable = cron:option(Flag,"enable", translate("Enable"))
enable.rmempty = false
enable.default = 0

week = cron:option(ListValue, "week", translate("Week Day"))
week:value(7, translate("Everyday"))
week:value(1, translate("Monday"))
week:value(2, translate("Tuesday"))
week:value(3, translate("Wednesday"))
week:value(4, translate("Thursday"))
week:value(5, translate("Friday"))
week:value(6, translate("Saturday"))
week:value(0, translate("Sunday"))
week.default = 0

hour = cron:option(Value, "hour", translate("Hour"))
hour.datatype = "range(0,23)"
hour.rmempty = false

minute = cron:option(Value, "minute", translate("Minute"))
minute.datatype = "range(1,59)"
minute.rmempty = false


local e = luci.http.formvalue("cbi.apply")
if e then
    io.popen("/etc/init.d/campus_network restart")
end

return m
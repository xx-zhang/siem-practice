package.cpath = "conf/lua/5.1/?.so;" 
local redis_connector = require("resty.redis.connector")
local json = require("cjson")

local modsec_log = ngx.req.get_headers()["X-ModSec-Log"]

local rc = redis_connector.new()
local red, err = rc:connect({
    url = "redis://172.17.0.1:32771",
})

if not red then
    ngx.say("failed to connect: ", err)
    return
end

local log_data = {
    remote_addr = ngx.var.remote_addr,
    time_local = ngx.var.time_local,
    request = ngx.var.request,
    status = ngx.var.status,
    modsec_message = ngx.var.modsec_message, -- ModSecurity 日志变量
    modsec_audit_log = ngx.var.modsec_audit_log , -- ModSecurity 日志变量
    modsec_audit_log = ngx.var.modsec_log , -- ModSecurity 日志变量
}

local log_json = json.encode(log_data)

local res, err = red:publish("topnsm_modsec_logs", log_json)
if not res then
    ngx.say("failed to publish: ", err)
    return
end

ngx.say("published: ", res)

local ok, err = red:set_keepalive(10000, 100)
if not ok then
    ngx.say("failed to set keepalive: ", err)
    return
end

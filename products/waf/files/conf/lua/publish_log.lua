package.cpath = "conf/lua/5.1/?.so;" 
local redis_connector = require("resty.redis.connector")
local json = require("cjson")

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
    body_bytes_sent = ngx.var.body_bytes_sent,
    http_referer = ngx.var.http_referer,
    http_user_agent = ngx.var.http_user_agent
}

local log_json = json.encode(log_data)

local res, err = red:publish("topnsm_nginx_logs", log_json)
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


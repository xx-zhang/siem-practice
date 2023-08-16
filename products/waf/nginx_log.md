# 



```lua
local redis = require("resty.redis")
local json = require("cjson")

local client = redis.connect("172.17.0.1", 32771) -- 连接到 Redis，更改 IP 和端口，如果需要
local log_key = "topnsm_nginx_logs" -- Redis 列表的 key

if not ok then
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

local res, err = red:publish(log_key, log_json)
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
```


## mosecurity 

```bash

log_by_lua_block {
        local redis = require "resty.redis"
        local red = redis:new()
        red:set_timeout(1000) -- 1 sec
        local ok, err = red:connect("127.0.0.1", 6379)
        if not ok then
            ngx.log(ngx.ERR, "failed to connect: ", err)
            return
        end

        local modsec_log = ngx.var.modsec_audit_log
        if modsec_log then
            local res, err = red:rpush("modsec_logs", modsec_log)
            if not res then
                ngx.log(ngx.ERR, "failed to send log: ", err)
            end
        end

        -- put it into the connection pool of size 100,
        -- with 0 idle timeout
        local ok, err = red:set_keepalive(0, 100)
        if not ok then
            ngx.log(ngx.ERR, "failed to set keepalive: ", err)
            return
        end
    }
}

```

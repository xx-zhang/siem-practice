package.cpath = "conf/lua/5.1/?.so;" 
local redis_connector = require("resty.redis.connector")
local json = require("cjson")

local modsec_log = ngx.req.get_headers()["X-ModSec-Log"]

for _, var_name in ipairs(vars_to_print) do
    local value = ngx.var[var_name]
    ngx.say(var_name .. ": " .. tostring(value))
end


ngx.say("----------------var---------------")
for k, v in pairs(ngx.var) do
    ngx.say(k .. ": " .. tostring(v))
end


ngx.say("----------------request params------------")
for k, v in pairs(ngx.req) do
    ngx.say(k .. ": " .. tostring(v))
end

ngx.say("--------------- nginx all params function test----------")
for k, v in pairs(ngx) do
    ngx.say(k .. ": " .. tostring(v))
end


ngx.say("--------------- nginx shared----------")
for k, v in pairs(ngx.shared) do
    ngx.say(k .. ": " .. tostring(v))
end

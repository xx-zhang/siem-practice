ngx.say("111111111111111111111111111")

local function print_ngx_vars()
    local ngx_var_mt = getmetatable(ngx.var)
    local ngx_var_index = ngx_var_mt.__index

    for k, v in pairs(ngx_var_index) do
        local value = ngx.var[k]
        ngx.say(k .. ": " .. tostring(value))
    end
end

print_ngx_vars()


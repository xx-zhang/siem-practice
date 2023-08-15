# waf

## 技术预研和选型
- [x] base ISO [openEuler-22.03-LTS-SP2-x86_64-dvd.iso](https://mirror.sjtu.edu.cn/openeuler/openEuler-22.03-LTS-SP2/ISO/x86_64/openEuler-22.03-LTS-SP2-x86_64-dvd.iso)
- [x] 直接使用 modsecurity 进行管理 
- [] 使用 nginx lua进行管理


## 开发使用
- 选型 https://github.com/ADD-SP/ngx_waf/
    - https://docs.addesp.com/ngx_waf/zh-cn/guide/installation.html#宝塔面板
- [nginx captcha](https://github.com/dengqiang2015/ngx_http_captcha_module/blob/master/ngx_http_captcha_module.c)


```conf

location / {
    ...
    modsecurity on;
    modsecurity_rules_file /path/to/modsecurity.conf;
    ...
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

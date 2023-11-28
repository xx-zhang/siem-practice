# hids
sysmon  auditd wazuh osquery


## osquery 
- 跨平台的 hids
- toolchain 
    - https://github.com/sttor/osquery-wazuh-response
    - https://github.com/osquery/osquery-toolchain
    - https://osquery.readthedocs.io/en/stable/deployment/yara/
- schema 
    - https://osquery.io/schema/5.10.2/

## wazuh 
- wazuh 

## auditd sysmon 
- auditd 进程快照
- sysmon 参考`sysmon-config` 

## 对比 
- 漏洞管理 / 基线  就用 openscap; osquery自己的，或者用 vuls
- 入侵检测
    - 文件查杀   - FIM
    - 异常登录   - login 
    - 密码破解   - auditd (secure)/ osqeury 
    - 高危命令   - progress / osqueryd 
        - 进程快照， 可以用 auditd
    - 恶意请求   - ip、domain、socket
    - 特权提升   - sudo
        - (隐蔽隧道)    - crontab 
        - 用户变更      - user 
    - 反弹shell - process/ 和进程一样 

- 高级防御
    - 网络攻击      - bepf 
    - 漏洞防御      - rasp 
    - java内存马    - rasp
    - 核心文件监控   - fim
    - 勒索防御

- 其他核心功能
    - 本地业务日志采集 tomcat/nginx等日志的风险过滤
    - 本地下载远程的工具插件，例如 下载 suricata/zeek/rita/passitivedns等工具


## java 内存吗对抗
- https://github.com/achuna33/Memoryshell-JavaALL
- https://github.com/c0ny1/java-memshell-scanner
    - java内存马   --------------------------------

# IPS 
> 鉴于 suricata4.1 -> 7.0 就是更新了一些工控协议和http2.0审计，所以不使用最新版本，使用 qnsm 版本
- suricata + dpdk 
    - https://github.com/iqiyi/qnsm
    - https://docs.suricata.io/en/latest/setting-up-ipsinline-for-linux.html
    - https://docs.suricata.io/en/suricata-7.0.0/setting-up-ipsinline-for-linux.html
    - dpdk 学习
        - https://dpdk-docs.readthedocs.io/en/latest/prog_guide/packet_classif_access_ctrl.html
        - https://zhuanlan.zhihu.com/p/397919872
        - https://blog.csdn.net/RelaxTech/article/details/129852693
        - https://blog.csdn.net/RelaxTech/article/details/129853369
        - https://blog.csdn.net/gengzhikui1992/article/details/103142848
        - aliyundrive/actanble ppts 
        - https://linuxcpp.0voice.com/?id=87

## suricata rule manger 
- https://gitee.com/redauzhang/suri_rules

## suricata base
> suricata基础版， 没有 dpdk
- 直接编译一个 centos7 的基础版本。

## suricata + DPDK
- dpdk 针对性的网卡进行自动打包成 `bin` 的相关产品化工作

```
[root@VM-4-14-centos ~]# ps -ef | grep qcloud
root      1376     1  0 Sep12 ?        00:00:25 /usr/local/qcloud/tat_agent/tat_agent
root      1845     1  0 Sep12 ?        00:00:33 /usr/local/qcloud/YunJing/YDLive/YDLive
root      2208  1845  0 Sep12 ?        00:25:33 /usr/local/qcloud/YunJing/YDEyes/YDService
root     11124  9754  0 15:00 pts/4    00:00:00 grep --color=auto qcloud
root     32376     1  0 14:21 ?        00:00:00 /usr/local/qcloud/stargate/bin/sgagent -d

# 删除tat_agent的python探测
ps -ef | grep qcloud | grep -v grep | awk '{print $2}' | xargs kill -9 
```

## lib 
```

libmaxminddb.so.0 => not found
libluajit-5.1.so.2 => not found
libpcap.so.1 => not found
libnet.so.1 => not found
libnetfilter_queue.so.1 => not found
libnfnetlink.so.0 => not found
libjansson.so.4 => not found
libyaml-0.so.2 => not found
libhs.so.5 => not found
libpcre2-8.so.0 => not found

```


## sruciata windows qt 
- 将东西安装到windows机器上，可以把日志发送到http, 接着处理http的日志到 rocksdb/leveldb 接着发送到平台


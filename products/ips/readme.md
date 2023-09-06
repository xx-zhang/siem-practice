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

## suricata base
> suricata基础版， 没有 dpdk
- 直接编译一个 centos7 的基础版本。

## suricata + DPDK
- dpdk 针对性的网卡进行自动打包成 `bin` 的相关产品化工作



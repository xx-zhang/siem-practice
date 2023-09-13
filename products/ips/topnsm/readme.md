# 顶尖便民路由开发
- 使用背景，双网卡环境中，在最小的配置下，开展最好的包捕获和检测性能。


## 特点
- 1. 全流量审计管理
- 2. 流量快速接入、高性能接入（dpdk）
- 3. 能够抗DDoS攻击
- 4. 日志发送到远程，通过redis/kafka发送。




## dpdk info 
- suricata with dpdk 
```
dpdk:
  eal-params:
    proc-type: primary

  # DPDK capture support
  # RX queues (and TX queues in IPS mode) are assigned to cores in 1:1 ratio
  interfaces:
    - interface: 0000:0b:00.0 # PCIe address of the NIC port
      # Threading: possible values are either "auto" or number of threads
      # - auto takes all cores
      # in IPS mode it is required to specify the number of cores and the numbers on both interfaces must match
      threads: 1
      promisc: true # promiscuous mode - capture all packets
      multicast: true # enables also detection on multicast packets
      checksum-checks: true # if Suricata should validate checksums
      checksum-checks-offload: false # if possible offload checksum validation to the NIC (saves Suricata resources)
      mtu: 1500 # Set MTU of the device in bytes
      # rss-hash-functions: 0x0 # advanced configuration option, use only if you use untested NIC card and experience RSS warnings,
      # For `rss-hash-functions` use hexadecimal 0x01ab format to specify RSS hash function flags - DumpRssFlags can help (you can see output if you use -vvv option during Suri startup)
      # setting auto to rss_hf sets the default RSS hash functions (based on IP addresses)

      # To approximately calculate required amount of space (in bytes) for interface's mempool: mempool-size * mtu
      # Make sure you have enough allocated hugepages.
      # The optimum size for the packet memory pool (in terms of memory usage) is power of two minus one: n = (2^q - 1)
      mempool-size: 65535 # The number of elements in the mbuf pool

      # Mempool cache size must be lower or equal to:
      #     - RTE_MEMPOOL_CACHE_MAX_SIZE (by default 512) and
      #     - "mempool-size / 1.5"
      # It is advised to choose cache_size to have "mempool-size modulo cache_size == 0".
      # If this is not the case, some elements will always stay in the pool and will never be used.
      # The cache can be disabled if the cache_size argument is set to 0, can be useful to avoid losing objects in cache
      # If the value is empty or set to "auto", Suricata will attempt to set cache size of the mempool to a value
      # that matches the previously mentioned recommendations
      mempool-cache-size: 257
      rx-descriptors: 1024
      tx-descriptors: 1024
      #
      # IPS mode for Suricata works in 3 modes - none, tap, ips
      # - none: IDS mode only - disables IPS functionality (does not further forward packets)
      # - tap: forwards all packets and generates alerts (omits DROP action) This is not DPDK TAP
      # - ips: the same as tap mode but it also drops packets that are flagged by rules to be dropped
      copy-mode: ips
      copy-iface: 0000:13:00.0 # or PCIe address of the second interface

    - interface: 0000:13:00.0
      threads: 1
      promisc: true
      multicast: true
      checksum-checks: true
      checksum-checks-offload: false
      mtu: 1500
      #rss-hash-functions: auto
      mempool-size: 65535
      mempool-cache-size: 257
      rx-descriptors: 1024
      tx-descriptors: 1024
      copy-mode: ips
      copy-iface: 0000:0b:00.0

# 原文链接：https://blog.csdn.net/RelaxTech/article/details/129853369
```


## install docker 
```bash


echo ">>> Install Docker-ce"
yum install -y yum-utils device-mapper-persistent-data lvm2 ;
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo ;
yum makecache fast ;
#yum -y install docker-ce-17.12.0.ce-1.el7.centos
yum -y install docker-ce ;
systemctl enable docker;
systemctl restart docker;


```

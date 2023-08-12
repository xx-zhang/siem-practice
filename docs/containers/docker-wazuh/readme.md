# docker-compose with wazuh
- 单 wazuh manager 的部署和快速使用


```bash
git clone -b 4.4.4 https://github.com/xx-zhang/docker-wazuh-4.git 
cd docker-wazuh-4/single-node

sysctl -w vm.max_map_count=262144
docker-compose -f generate-indexer-certs.yml run --rm generator
docker-compose up -d
```

# wazuh管理控制台

## create a node CENTOS 
- 参考 agent 页面的接入管理

### 待办
- [x] 查看wazuh-agent的源码分析各个进程调用的原理，配置文件转换，其他集成和优化
- [] 打包 agent 为通用的agent, 并修改其中的部分logo信息
- [] 查看att&ck在默认的encode中的位置，尝试进行u关联
- [] 资源控制，额外插件开发
- [] monitor 监控规则的扩展和相关优化
- [] `channel webhook` 和 [golang grpc server](https://github.com/grpc/grpc-go) [rust](https://github.com/hyperium/tonic) 的创建开发

## 创建监控
- []()
- []() 

## dql 
- [dql-2.6](https://opensearch.org/docs/2.6/dashboards/discover/dql/)



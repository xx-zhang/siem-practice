# 获取goalng和开发
```bash

wget -c -N https://studygolang.com/dl/golang/go1.19.12.linux-amd64.tar.gz && \
    tar xf go1.19.12.linux-amd64.tar.gz -C /usr/local && \
    ln -sf /usr/local/go/bin/go /usr/bin/go 

go env -w GOPROXY=https://goproxy.cn,direct

go mod tidy
go build 
```

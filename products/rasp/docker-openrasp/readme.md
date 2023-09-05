## sprintboot-webgoat8.1 快速接入进行测试

```
https://github.com/WebGoat/WebGoat/releases/download/v8.1.0/webgoat-server-8.1.0.jar
https://github.com/Tencent/TencentKona-11/releases/download/kona11.0.20/TencentKona-11.0.20.b1-jdk_linux-x86_64.tar.gz
https://packages.baidu.com/app/openrasp/release/1.3.7/rasp-java.tar.gz

#ref: https://rasp.baidu.com/doc/install/manual/spring-boot.html
#ref https://blog.csdn.net/weixin_43681778/article/details/117718655

cloud.enable: true
cloud.backend_url: http://9.135.116.47:8086/
cloud.app_id: ce0988d9b11b756b1b7cae7f450a0857b8a4959c
cloud.app_secret: 1hJ7UHrEFNCKQEytxLXVf6RjOnNT9cIw7Cx172J7Yzw
cloud.heartbeat_interval: 90

chmod 777 -R rasp
java -jar RaspInstall.jar -nodetect -install ../webapp \
    -backendurl http://9.135.116.47:8086 \
    -appsecret 1hJ7UHrEFNCKQEytxLXVf6RjOnNT9cIw7Cx172J7Yzw \
    -appid ce0988d9b11b756b1b7cae7f450a0857b8a4959c

java --add-opens java.base/jdk.internal.loader=ALL-UNNAMED -javaagent:/home/webgoat/webapp/rasp/rasp.jar -jar /home/webgoat/webapp/springboot-server-8.1.0.jar 
```

## 测试 IAST


# start guide 

```shell
#iptables -t nat -F 
#iptables -F 

iptables -I INPUT -j NFQUEUE
iptables -I OUTPUT -j NFQUEUE

/topnsm/idps/bin/suricata  -c /etc/suricata/suricata.yaml -q 0

```


## 
```bash


```

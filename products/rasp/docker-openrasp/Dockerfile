FROM ubuntu:22.04 


RUN apt -yqq update
RUN apt install vim wget -y
RUN apt install  -y

RUN wget https://packages.baidu.com/app/openrasp/release/1.3.7/rasp-cloud.tar.gz
RUN tar zxvf /rasp-cloud.tar.gz
RUN rm /rasp-cloud.tar.gz
COPY conf/app.conf /rasp-cloud-2022-01-28/conf/app.conf

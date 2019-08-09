FROM alpine:latest
MAINTAINER luka.cehovin@gmail.com

ENV FRP_VERSION 0.28.0
ENV DOCKER_GEN_VERSION 0.7.4

RUN apk add --no-cache wget ca-certificates tar runit

RUN mkdir /frp/ && cd /frp && \
    wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_amd64.tar.gz -O frp.tar.gz && \
    tar xvzf frp.tar.gz && mv frp_${FRP_VERSION}_linux_amd64/frpc /usr/local/bin/ && cd / && rm -rf /frp

RUN mkdir /dockergen/ && cd /dockergen && \
    wget https://github.com/jwilder/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-alpine-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz -O dockergen.tar.gz && \
    cd /usr/local/bin && tar xvzf /dockergen/dockergen.tar.gz && rm -rf /dockergen

COPY start_runit /sbin/
COPY etc /etc/

CMD ["/sbin/start_runit"]


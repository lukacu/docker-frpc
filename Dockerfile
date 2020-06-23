FROM golang:alpine AS build

ENV FRP_VERSION 0.33.0
ENV DOCKER_GEN_VERSION 0.7.4

RUN apk add --no-cache git make gcc linux-headers libc-dev

#RUN go get github.com/fatedier/frp@v${FRP_VERSION}
#RUN go get github.com/jwilder/docker-gen@${DOCKER_GEN_VERSION}
RUN git clone https://github.com/fatedier/frp $GOPATH/src/github.com/fatedier/frp && git clone https://github.com/jwilder/docker-gen $GOPATH/src/github.com/jwilder/docker-gen
RUN cd $GOPATH/src/github.com/fatedier/frp && git checkout v${FRP_VERSION} && make
RUN cd $GOPATH/src/github.com/jwilder/docker-gen && git checkout ${DOCKER_GEN_VERSION}
RUN go get github.com/robfig/glock
RUN cd $GOPATH/src/github.com/jwilder/docker-gen && make get-deps
RUN cd $GOPATH/src/github.com/jwilder/docker-gen && make

FROM alpine:latest
MAINTAINER luka.cehovin@gmail.com

RUN apk add --no-cache ca-certificates runit

COPY --from=build /go/src/github.com/fatedier/frp/bin/frpc /usr/local/bin/
COPY --from=build /go/src/github.com/jwilder/docker-gen/docker-gen /usr/local/bin/

COPY start_runit /sbin/
COPY etc /etc/

# Set admin user and pws so that config reload can be triggered. The admin port is not exposed by default.
ENV FRPC_ADMIN_USER admin
ENV FRPC_ADMIN_PWD admin

CMD ["/sbin/start_runit"]


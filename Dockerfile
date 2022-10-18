FROM golang:alpine AS builder
RUN apk update && apk add --no-cache git
WORKDIR /go/src/xray/core
RUN git clone --progress https://github.com/XTLS/Xray-core.git . && \
    go mod download && \
    CGO_ENABLED=0 go build -o /tmp/xray -trimpath -ldflags "-s -w -buildid=" ./main

FROM debian:sid

RUN set -ex\
    && apt update -y \
    && apt upgrade -y \
    && apt install -y wget unzip qrencode\
    && apt install -y nginx\
    && apt autoremove -y

COPY --from=builder /tmp/xray /usr/bin
COPY wwwroot.tar.gz /wwwroot/wwwroot.tar.gz
COPY conf/ /conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

CMD /entrypoint.sh

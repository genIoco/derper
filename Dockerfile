FROM golang:latest AS builder
WORKDIR /app

RUN go install tailscale.com/cmd/derper@main


FROM debian:bookworm-slim
WORKDIR /app

# ========= CONFIG =========
# - derper args
ENV DERP_ADDR :443
ENV DERP_HTTP_PORT 80
ENV DERP_STUN_PORT 3478
ENV DERP_DOMAIN=example.com
ENV DERP_CERTS=/app/certs/
ENV DERP_STUN true
ENV DERP_VERIFY_CLIENTS false
# ==========================

# apt
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /app/certs

COPY --from=builder /go/bin/derper /app/derper

# start derper
CMD /app/derper --hostname=$DERP_DOMAIN \
    --certmode=manual \
    --certdir=$DERP_CERTS \
    --a=$DERP_ADDR \
    --stun=$DERP_STUN  \
    --stun-port=$DERP_STUN_PORT \
    --http-port=$DERP_HTTP_PORT \
    --verify-clients=$DERP_VERIFY_CLIENTS

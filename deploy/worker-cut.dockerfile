FROM golang:1.22-bookworm AS builder

ENV GO111MODULE=on \
    CGO_ENABLED=0

WORKDIR /build

COPY . .

RUN go mod download

RUN make worker

FROM debian:bookworm AS app

WORKDIR /app

ENV TZ=Asia/Shanghai

ENV FINALRIP_EASYTIER_HOST 10.126.126.251

COPY --from=mwader/static-ffmpeg:7.0.2 /ffmpeg /usr/local/bin/
COPY --from=mwader/static-ffmpeg:7.0.2 /ffprobe /usr/local/bin/

COPY --from=builder /build/worker/worker /app/
COPY --from=builder /build/conf/finalrip.yml /app/conf/

CMD ["/app/worker", "cut"]

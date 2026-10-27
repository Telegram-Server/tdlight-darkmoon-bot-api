FROM ubuntu:24.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends g++ make cmake gperf libssl-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/opt/telegram-bot-api \
 && cmake --build build --target telegram-bot-api -j"$(nproc)" \
 && cmake --install build --strip \
 && rm -rf build

FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates libssl3t64 zlib1g \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --system --home-dir /var/lib/telegram-bot-api --create-home telegram-bot-api

COPY --from=build /opt/telegram-bot-api/bin/telegram-bot-api /usr/local/bin/telegram-bot-api

USER telegram-bot-api
WORKDIR /var/lib/telegram-bot-api
VOLUME /var/lib/telegram-bot-api
EXPOSE 8081

# TELEGRAM_API_ID and TELEGRAM_API_HASH must be provided via environment variables
ENTRYPOINT ["telegram-bot-api", "--dir=/var/lib/telegram-bot-api", "--temp-dir=/tmp"]

### The Deb install is just a repack of the official Proton Mail Bridge deb
### package with fewer dependencies. It's kept for legacy reasons; prefer the
### build-from-source image for most use cases.

FROM debian:sid-slim AS build

COPY install.sh PACKAGE /
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        binutils \
        ca-certificates \
        wget \
    && rm -rf /var/lib/apt/lists/*

# Repack deb (removes unnecessary dependencies and produces /protonmail.deb)
RUN bash /install.sh

FROM debian:sid-slim

LABEL org.opencontainers.image.title="protonmail-bridge-docker (deb)" \
      org.opencontainers.image.description="Proton Mail Bridge, repacked from the official .deb." \
      org.opencontainers.image.source="https://github.com/illusorykitsune/protonmail-bridge-docker" \
      org.opencontainers.image.licenses="MIT"

EXPOSE 25/tcp
EXPOSE 143/tcp

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=60s \
    CMD pgrep -f protonmail-bridge >/dev/null || exit 1

WORKDIR /protonmail

# Copy bash scripts
COPY gpgparams entrypoint.sh PACKAGE /protonmail/
COPY --from=build /protonmail.deb /tmp/protonmail.deb

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        /tmp/protonmail.deb \
        ca-certificates \
        libsecret-1-0 \
        pass \
        procps \
        socat \
    && rm -rf /var/lib/apt/lists/* /tmp/protonmail.deb

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]

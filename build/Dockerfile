# The build image could be golang, but it currently does not support riscv64.
# Only debian:sid does, at the time of writing.
FROM debian:sid-slim AS build

ARG version

# Install build dependencies. --no-install-recommends trims the build image
# (the stage is discarded, but it makes layer-cache hits cheaper).
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        golang \
        libcbor-dev \
        libfido2-dev \
        libsecret-1-dev \
        libssl-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Build
ADD https://github.com/ProtonMail/proton-bridge.git#${version} /build/
WORKDIR /build/
RUN make build-nogui vault-editor

FROM debian:sid-slim

# OCI metadata — replaces the legacy LABEL maintainer (which still named the
# upstream maintainer after the fork).
LABEL org.opencontainers.image.title="protonmail-bridge-docker" \
      org.opencontainers.image.description="Proton Mail Bridge, built from source, for Docker." \
      org.opencontainers.image.source="https://github.com/illusorykitsune/protonmail-bridge-docker" \
      org.opencontainers.image.licenses="MIT"

EXPOSE 25/tcp
EXPOSE 143/tcp

HEALTHCHECK --interval=30s --timeout=10s --retries=3 --start-period=60s \
    CMD pgrep -f proton-bridge >/dev/null || exit 1

# Install runtime dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        libcbor0.10 \
        libfido2-1 \
        libsecret-1-0 \
        pass \
        procps \
        socat \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint and gpg params
COPY gpgparams entrypoint.sh /protonmail/

# Copy built binaries in a single layer
COPY --from=build /build/bridge /build/proton-bridge /build/vault-editor /protonmail/

ENTRYPOINT ["bash", "/protonmail/entrypoint.sh"]

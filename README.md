# Proton Mail Bridge Docker Container

An unofficial Docker container of [Proton Mail Bridge](https://proton.me/mail/bridge). This is a community fork of [shenxn/protonmail-bridge-docker](https://github.com/shenxn/protonmail-bridge-docker).

## Image

Images are published to the GitHub Container Registry:

```
ghcr.io/illusorykitsune/protonmail-bridge-docker
```

Two image types are produced:

- `deb` — based on the official [.deb release](https://proton.me/mail/bridge). `amd64` only.
- `build` — built from [Proton Bridge source](https://github.com/ProtonMail/proton-bridge). Supports `amd64`, `arm64`, `arm/v7`, and `riscv64`.

| tag                | description                         |
| ------------------ | ----------------------------------- |
| `latest`           | latest `deb` image                  |
| `<version>`        | specific version, `deb` image       |
| `build`            | latest `build` image                |
| `<version>-build`  | specific version, `build` image     |

## Initialization

Before first use you need to add your Proton account. Run:

```
docker run --rm -it -v protonmail:/root ghcr.io/illusorykitsune/protonmail-bridge-docker init
```

When the [Bridge CLI](https://proton.me/support/bridge-cli-guide) prompt appears, run `login` and follow the instructions. Then `info` will show the IMAP/SMTP username and password. Use `exit` (and `CTRL+C` if needed) to leave the container.

## Run

```
docker run -d --name=protonmail-bridge \
  -v protonmail:/root \
  -p 1025:25/tcp -p 1143:143/tcp \
  --restart=unless-stopped \
  ghcr.io/illusorykitsune/protonmail-bridge-docker
```

Or, using the provided [`docker-compose.yml`](docker-compose.yml):

```
docker compose up -d
```

## Security

The command above exposes Bridge to the host network. On untrusted networks or machines with a public IP, either place the container behind a firewall or bind the ports to localhost only:

```
-p 127.0.0.1:1025:25/tcp -p 127.0.0.1:1143:143/tcp
```

If you only need to send mail (e.g. notifications), you can omit `-p 1143:143/tcp` and expose SMTP only.

## Kubernetes

A Helm chart by [@Eagleman7](https://github.com/Eagleman7) is available at [k8s-at-home/charts](https://github.com/k8s-at-home/charts/tree/master/charts/stable/protonmail-bridge); context in [shenxn/protonmail-bridge-docker#23](https://github.com/shenxn/protonmail-bridge-docker/issues/23). For a Helm-less setup, see the guide by [@ghudgins](https://github.com/ghudgins) in [shenxn/protonmail-bridge-docker#6](https://github.com/shenxn/protonmail-bridge-docker/issues/6).

## Build from source

```
cd build   # or: cd deb
docker build .
```

The `Dockerfile` and entrypoint scripts handle downloading, building and packaging. `buildx` can be used for multi-arch builds.

## Bridge CLI

The interactive shell exposed by `init` is the full Bridge CLI; it can switch between combined/split mode, change the proxy, etc. See Proton's [official guide](https://proton.me/support/bridge-cli-guide).

## Credits

This fork builds on the work of many people. Thanks to:

| Contributor | Contribution |
| --- | --- |
| [Proton AG](https://proton.me/mail/bridge) | Proton Mail Bridge itself |
| [Hendrik Meyer (T4cC0re)](https://gitlab.com/T4cC0re/protonmail-bridge-docker) | The original Docker scripts this project descends from |
| [shenxn](https://github.com/shenxn) | Created and long-time maintainer of `shenxn/protonmail-bridge-docker`, the direct parent of this fork |
| [Simon Ungar Felding (simonfelding)](https://github.com/simonfelding) | Build parallelization, ARM build fixes, vault editor support, switch to `debian:sid-slim`, buildx/digest fixes |
| [schklom](https://github.com/schklom) | CI trigger improvements |
| [Mark Monteiro](https://github.com/marknr) | Docker Compose documentation and example |
| [@Eagleman7](https://github.com/Eagleman7) | Helm chart for Kubernetes |
| [@ghudgins](https://github.com/ghudgins) | Kubernetes-without-Helm guide |

## License

See [LICENSE](LICENSE).

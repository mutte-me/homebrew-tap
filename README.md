<p align="center">
  <img src="assets/mutte-wordmark.svg" alt="Mutte" width="780">
</p>

# Mutte Homebrew tap

Install the Mutte terminal client on Linux or macOS:

```bash
brew install mutte-me/tap/mutte
```

Homebrew selects the native release for Linux x86_64/ARM64 or macOS
Intel/Apple Silicon. Upgrade with `brew update && brew upgrade mutte`.

The same release is available through Mutte's standalone installer:

```bash
curl -sfL https://get.mutte.me | sh -
```

> Mutte is alpha software. Its external protocol, cryptography, backend, and
> client audits are not complete. Do not rely on it for high-risk
> communication.

Client source, release archives, checksums, and security policy live in
[`mutte-me/mutte-client`](https://github.com/mutte-me/mutte-client).

## Formula updates

The hourly `Update formula` workflow follows the reviewed `INSTALL_VERSION`
channel in `mutte-client`. When that channel advances, it validates all four
published archives and checksum companions, renders their GitHub SHA-256
digests into the formula, and opens a protected pull request. The tap uses only
its repository-scoped `GITHUB_TOKEN`; it has no credential that can write to
the client repository.

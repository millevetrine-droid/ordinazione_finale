## GitHub Copilot Chat

- Extension Version: 0.32.3 (prod)
- VS Code: vscode/1.105.1
- OS: Windows

## Network

User Settings:
```json
  "github.copilot.advanced.debug.useElectronFetcher": true,
  "github.copilot.advanced.debug.useNodeFetcher": false,
  "github.copilot.advanced.debug.useNodeFetchFetcher": true
```

Connecting to https://api.github.com:
- DNS ipv4 Lookup: 140.82.121.6 (8 ms)
- DNS ipv6 Lookup: Error (5 ms): getaddrinfo ENOTFOUND api.github.com
- Proxy URL: None (23 ms)
- Electron fetch (configured): HTTP 200 (26 ms)
- Node.js https: HTTP 200 (88 ms)
- Node.js fetch: HTTP 200 (108 ms)

Connecting to https://api.individual.githubcopilot.com/_ping:
- DNS ipv4 Lookup: 140.82.113.21 (5 ms)
- DNS ipv6 Lookup: Error (5 ms): getaddrinfo ENOTFOUND api.individual.githubcopilot.com
- Proxy URL: None (1 ms)
- Electron fetch (configured): HTTP 200 (357 ms)
- Node.js https: HTTP 200 (352 ms)
- Node.js fetch: HTTP 200 (353 ms)

## Documentation

In corporate networks: [Troubleshooting firewall settings for GitHub Copilot](https://docs.github.com/en/copilot/troubleshooting-github-copilot/troubleshooting-firewall-settings-for-github-copilot).
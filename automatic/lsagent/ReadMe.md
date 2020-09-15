# <img src="https://cdn.jsdelivr.net/gh/comnam90/chocolatey-packages@6c54409dc9a3563fb0655a7838f442cca7357275/icons/LsAgent.png" width="48" height="48"/> [lsagent](https://chocolatey.org/packages/lsagent)

![Chocolatey](https://img.shields.io/chocolatey/dt/lsagent?logo=chocolatey)

LsAgent is a small, lightweight application that you can install on your Windows, Mac and Linux devices. It gathers the asset data locally and then sends it back to your Lansweeper installation, either by using a direct push or through Lansweeper's cloud-hosted relay service.

## Features

* Automatically collect an inventory from a computer and sends the data back to a Lansweeper installation, either directly or through the lansweeper relay server in the cloud.
* Does not require scanning credentials in Lansweeper.
* Does not require administrative privileges to be able to scan.
* Does not require configuration of your computers' firewalls for scanning. It does require an outbound connection to your Lansweeper installation or cloud relay server.

## Package parameters

- `/Prefix` - Installation Directory (Optional). Default: `C:\Program Files (x86)/LansweeperAgent`
- `/Server` - FQDN, NetBios or IP of the Lansweeper Scanning Server.
- `/Port` - Listening Port on the Scanning Server (Optional). Default: `9524`.
- `/AgentKey` - Cloud Relay Authentication Key (Optional).

Example: `choco install lsagent --params "/Server=lansweepersvr"`

## Notes

None

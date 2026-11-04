# Network hardening

Laptop that moves between networks, so the baseline is "nothing inbound, anywhere".
Applied by `system/install-system.sh`; the fish toggles are managed by chezmoi.

## What is configured

| Piece | Where | Effect |
| --- | --- | --- |
| ufw | `ufw default deny incoming` / `allow outgoing` | Nothing can connect in on any network |
| LLMNR off | `system/etc/NetworkManager/conf.d/10-privacy.conf`, `system/etc/systemd/resolved.conf.d/10-no-llmnr.conf` | Removes the spoofable legacy name lookup. mDNS stays on so casting / `.local` still work |
| Wi-Fi MAC | same NetworkManager file, `wifi.cloned-mac-address=stable` | Random MAC, stable per network, different across networks |
| sshd | `system/etc/ssh/sshd_config.d/10-hardening.conf` | Key-only, no root login. The service stays **disabled**; `lan-on` starts it |

## lan-on / lan-off (fish)

- `lan-on` detects the current subnet, asks for confirmation, then opens TCP 3000, 3001, 4000, 5000, 5173, 8080, 8081 and rate-limited SSH (22) to that subnet only, and starts `sshd`.
- `lan-off` deletes every ufw rule tagged `lan-mode` and stops `sshd`.
- They are toggles on purpose: a home subnet like `192.168.0.0/24` is also used by many routers elsewhere, so permanent LAN allow rules could match a café or hotel.
- SSH needs your public key in `~/.ssh/authorized_keys` first (password login is off).

## Docker

ufw does not filter Docker-published ports (Docker inserts its rules first). Bind published ports to localhost in compose files, e.g. `ports: ['127.0.0.1:6379:6379']`.

## Per-connection settings (not tracked)

Saved Wi-Fi profiles contain the password, so they are not in this repo. Reapply by hand on a new install, using your own connection name:

```bash
nmcli con mod "<SSID>" 802-11-wireless.powersave 2 \
    ipv4.dns "1.1.1.1 8.8.8.8" ipv4.ignore-auto-dns yes
nmcli con up "<SSID>"
```

`powersave 2` disables Wi-Fi power saving (less jitter on weak signal); the DNS pair avoids a flaky LAN-provided resolver.

## Check

```bash
sudo ufw status verbose
resolvectl status | grep -E 'LLMNR|mDNS'
ip link show wlan0        # MAC should differ from the hardware address
```

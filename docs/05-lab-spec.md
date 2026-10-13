# 05 — Lab Spec

## Inventory
| Asset | Details |
|---|---|
| Mac (this host) | macOS, en0 on `192.168.1.0/24`, IP `192.168.1.49`. All `tools/` scripts run here. |
| Xbox Series X | User-owned, current firmware `10.0.26100.xxxx` (verify live). Ethernet + WiFi. |
| USB drives | 2× flash drives. Format plan: one **exFAT** (media/transfer tests), one **NTFS** (OSU1 recovery + NTFS-override experiments). |
| Phone | Xbox app — controller substitute during setup. |

## Network setup (operator to do)
1. Router: create **DHCP reservation** for the console as soon as it's identified (record MAC in `recon/`). Recommend naming it `xbox-lab`.
2. Optional but ideal: separate 2.4/5GHz SSID or VLAN `xbox-lab-net` for the console to keep experiment traffic isolated. Not required.
3. Keep the Mac on the same L2 segment as the console (it is: en0).

## Mac software to install (Homebrew)
```bash
brew install nmap python3 dnssd-tools   # nmap for deeper scans, python3 for parsers
```
Native fallbacks already used by `tools/`: `nc`, `curl`, `dns-sd`, `arp`, `ping`.

## Windows-on-Mac (for XTF tooling, Phase 1+)
XTF (`XtfFileIO`, `XtfRemoteRun`, `XboxManager`) is Windows-only. Options in preference order:
1. **UTM** (free, virtualization) — Windows 11 ARM + x64 emulation is slow but XTF tools are small.
2. **Parallels** if licensed.
3. Any spare Windows PC on the LAN — equally good; XTF talks to the console over network.
Install "Xbox Game Development Kit" toolset in the VM/PC only when Phase 1 is reached.

## USB drive roles
| Drive | Label | Contents |
|---|---|---|
| A | `XMOD-A` exFAT | Media playback/parser test files, test content |
| B | `XMOD-B` NTFS | OSU1 recovery package (kept current), NTFS-override test tree per wiki `boot/usb-ntfs-overrides` |

## Backups & safety
- Before Phase 2 changes: export WDP app/package list + settings to `recon/`.
- Console rollback documented in `06-devmode-playbook.md`.
- All scan output → `recon/YYYYMMDD_HHMM_<name>.txt`, never into `docs/`.

## Credentials hygiene
- WDP user/pass → `recon/credentials.local` (add to `.gitignore`). Never in docs, never committed.

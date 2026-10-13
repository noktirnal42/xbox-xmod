# 03 — Attack Surface Inventory (reachable from: this Mac, LAN, USB drives)

Each surface lists: how we reach it, tools, and current verification status.

## A. Network — retail mode (console online, no dev mode)

| Surface | Reach | Verify via |
|---|---|---|
| SSDP/UPnP (UDP 1900) | Any LAN host | `discover_xbox.sh` (SSDP probe) |
| mDNS (UDP 5353) | Any LAN host | `dns-sd -B _http._tcp local.` etc. |
| Xbox Live rendezvous ports (88/3074 UDP-TCP) | LAN-visible; handshake only | port scan |
| Unmapped TCP/UDP listeners | LAN | full port scan `xbox_portscan.sh` |
| WFP firewall behavior | probe responses | scan diffs dev vs retail |

Do NOT attack these; retail-mode surface is for **mapping only** — baseline before/after Dev Mode is enabled.

## B. USB flash drives — retail mode

| Surface | Notes | Status |
|---|---|---|
| **NTFS `$`-override tree** | Files at NTFS-USB root trigger cold-boot ops — incl. Gen9: `$DumpSystemOS`/`$DumpHostOS` (OS **memory dumps** to USB, `.dmpx` encrypted), `$SystemUpdate\consoles.txt` (console writes its build version), `hwinit.cfg` (board/voltage/clock overrides — brick risk, signature status UNVERIFIED), `$NoSurface` (HostOS-mounted volume), `$Diagnosis\debug.bin` (retail debug capability cert), ETW/trace taps | See `knowledge/usb-ntfs-overrides.md` + `tools/usb_prep.sh`; this is our primary USB vector |
| OSU1 offline update package | Official recovery/update from `support.xbox.com` → USB; public read-only artifact we can download & analyze offline | Phase 0 artifact collection |
| Controllers/accessories (USB HID, GIP) | Input provider "Xiphos" in SystemOS; USB HID parsing surface | UNVERIFIED on Series |
| Storage expansion card | Proprietary auth (ASIC handshake) — out of reach without hardware | out of scope |

## C. Dev Mode surfaces (after Phase 1) — primary working environment

| Surface | Port/Path | Notes |
|---|---|---|
| Xbox Device Portal (WDP) | HTTPS :11443, basic auth | Full REST API: process mgmt, file upload/download, screenshots, settings, **unattendedsetup boot scripts**, Xbox Info (OS build) |
| SSH | :22 | Dev sandbox shell in SystemOS (user `DevToolsUser` or configured user) |
| SMB developer folder | :445 | `\\<ip>\DevelopmentFiles` — loose app deployment, scratch transfer |
| Sirep protocol | :1025 family | Original dev/comms protocol; historically exploitable (VSProfiling lineage) — UNVERIFIED current state |
| XTF (Xbox Test Framework) | from Windows PC | Richest API (XtfFileIO, XtfRemoteRun, console control). We are on macOS → run inside a Windows VM (UTM/Parallels) — see `05-lab-spec.md` |
| UWP app deployment | via WDP/SMB | Signed-by-us code execution inside the dev sandbox — the base of the soft-mod |
| `unattendedsetup-apply` | WDP API | **Persistence**: script runs at every boot of the dev console |

## D. Public read-only cloud (no auth, no write)

- OS update CDN + `update.cfg` (wiki `xbox-live/update-cdn`, `file-formats/update-cfg`): lets us pull **official firmware packages** for any update group → offline static analysis and **differential patch analysis** between builds.
- Public wikis/blogs/GitHub: harvested by `agents/02` + polled by `agents/05` (`tools/monitor_sources.sh`).

## E. What we deliberately do NOT touch
- Xbox Live authenticated APIs, account endpoints, matchmaking — nothing.
- Other LAN hosts beyond identifying what's ours.
- Disc drive firmware / hardware glitching (BLISS-class) unless everything else fails and operator approves.

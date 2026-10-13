# 08 — Persistence Spec (Phase 2 core deliverable)

## Primitive
WDP `unattendedsetup` APIs set a **boot script executed by the console at every dev-mode boot** (documented on xboxoneresearch wiki + MS docs). This is the sanctioned persistence hook inside the dev boundary.

## Design
```
[boot] bootsh/unattended runner → boot.ps1 (console, persistent storage)
boot.ps1:
  1. append boot record (timestamp, OS build, uptime) to /DevFiles/xmod/bootlog.txt
  2. verify daemon present; (re)start xmodd (PowerShell background job / process)
  3. xmodd: HTTPS-beacon to Mac (192.168.1.49:8443) w/ console state; listens for WFP/SSH/SMB enable cmds
  4. self-check: if script missing → we lost persistence → beacon "PERSIST_LOST"
```

### Versioning & safety
- `boot.ps1` idempotent; every change bumped `vN` and logged.
- Keep a `boot.ps1.bak` on the Mac; `wdp.sh bootscript show` before every overwrite.
- Kill-switch documented: `wdp.sh bootscript clear` (then verify with `show`).

### Storage locations (verify in Phase 1 which survive reboot)
- `D:\DevelopmentFiles\` (dev scratch) — primary
- LooseApps folder — secondary
- Registry (via admin, if we get one) — tertiary (Artifice used `HKLM\...\Bootsh\Parameters\Commands`)

## Mac-side listener (xmodd-beacon receiver)
- python3 HTTPS server, self-signed, port 8443, logs to `recon/beacons/`.
- Spec'd in Phase 2 implementation task; keep minimal (no remote code push until Phase 4 needs it).

## What "done" means (rung 3)
- Cold-boot console (dev mode) → bootlog gains a new entry within N minutes, Mac receives beacon.
- Survives: reboot, power cycle, WDP restart, app uninstall.
- Documented rollback + a "leave dev mode" caveat (leaving dev mode wipes dev content — persistence dies with it, which is by design; retail persistence is rung 4/5 territory).

## Test matrix
| # | Test | Expected |
|---|---|---|
| P1 | apply trivial script (echo to log) | log entry at next boot |
| P2 | reboot ×3 | 3 entries |
| P3 | power cycle (unplug) | entry |
| P4 | script with error | console boots normally; runner logs error |
| P5 | clear + reboot | no entries; console clean |

Operator runs tests; results → `recon/YYYYMMDD_HHMM_persistence-P#.md`.

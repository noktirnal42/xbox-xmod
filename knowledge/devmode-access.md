# Dev-mode access details (SSH, SMB, WDP, elevation lineage)

Sources: xboxoneresearch wiki `development/setup-dev-mode/`, `exploits/artifice-devmode-elevation/` (retrieved 2026-10-12).

## SSH (dev mode)
- Port 22, user **`DevToolsUser`**
- Password: the **"Show Visual Studio Pin"** value from Dev Home, **or** the WDP/SMB password

## SMB
- `\\<console-ip>\` (DevelopmentFiles) — same creds as WDP user

## Artifice (2023) — CONFIRMED PATCHED on our firmware
- Granted **admin account in SystemOS** (`admin`/`admin`) from a dev-mode console, via OpenSSH service vulnerability (devmode).
- Patched in **10.0.26100.1968** (xb_flt_2408ge.240821-1830, 2024-08-28). Our console: 10.0.26100.9438 → **patched**.
- Writeup: https://kudayasu.github.io/an-autopsy-of-artifice/ ; code: https://github.com/Kudayasu/Artifice
- **Technique still valuable**: post-elevation SYSTEM shell via `bootsh`:
  ```
  REG ADD HKLM\SYSTEM\ControlSet001\Services\Bootsh\Parameters\Commands /v Xrun /t REG_SZ /d "telnetd.exe cmd.exe 23" /f
  sc start bootsh
  ```
  → telnet :23 = SYSTEM shell. Restore afterwards: `xrun.exe SystemBootTasks`.
  → `bootsh` service = a **known attacker-controlled command execution primitive** if we ever get admin in SystemOS. Priority target for re-analysis in Phase 3/4.

## Escalation lineage (all devmode, all presumed patched — verify per build)
- VSProfiling (2018) → UnattendedUtilities (2019) → System.xvd RW overlay (2019) → Artifice (2023)
- Pattern: elevated service or scheduled utility whose input/path is controllable from the UWP dev sandbox.

## WDP endpoints of record
- Base: `https://<ip>:11443` (self-signed → `curl -k`)
- `/api/os/machinename`, `/api/os/info`, `/api/resourcemanager/processes`, `/api/appx/packagemanager/packages`, `/api/filesystem/files`
- `/api/ext/unattendedsetup/apply|default|test|configure` (boot script — persistence primitive)
- `/api/ext/xbox-info` (OS build/sandbox info), `/api/ext/smb-developerfolder`

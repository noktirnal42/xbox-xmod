# 06 — Dev Mode Playbook (active runbook)

Phase 1+ operator runbook. Every command here is against the user's own console.

## Step 1 — Console online (operator, in progress)
Ethernet first → verify with `tools/discover_xbox.sh`. Then switch to WiFi via Xbox app as controller (Settings → General → Network settings).

## Step 2 — Activate Dev Mode
1. Create a free individual developer account at the Microsoft Partner Center (dev.microsoft.com) — browser work, no console interaction.
2. On console (phone-as-controller): install **Xbox Dev Mode** app from the store, launch, sign in, select "Activate".
3. Console reboots into Dev Mode (home screen = Dev Home). Retail mode returns via "Leave dev mode" (takes ~5 min, wipes dev content).
4. Record: OS build shown in Dev Home → `recon/YYYYMMDD_HHMM_devmode-enabled.md`.

Note: in Dev Mode the console cannot play retail games or sign into Xbox Live as normal. Keep that in mind for scheduling.

## Step 3 — Enable Device Portal & credentials
Dev Home → Remote Access → "Enable Xbox Device Portal"; set username/password.
- Save to `recon/credentials.local` (never commit).
- Verify: `./tools/wdp.sh <ip> <user> <pass> info`

## Step 4 — Verify all dev surfaces from Mac
```bash
./tools/xbox_portscan.sh <ip>            # expect 22, 445, 11443 (+ extras)
ssh DevToolsUser@<ip>                    # dev sandbox shell
mount_smbfs //DevToolsUser@<ip>/DevelopmentFiles ./mnt  # SMB (cred = WDP user)
```

## Step 5 — Deploy first UWP app (from Mac)
The zero-dependency path: package a minimal signed UWP and register it via WDP `AppPackageManager`. Full walkthrough to be produced as `docs/07-uwp-deployment.md` in Phase 1 (needs a macOS signing setup: self-signed cert + `makeappx` equivalent via `zip` + manifest edit — UNVERIFIED on macOS; Windows VM fallback documented in `05-lab-spec.md`).

## Step 6 — Persistence (Phase 2 core)
```bash
# Boot script via Device Portal API (runs at every dev-mode boot):
./tools/wdp.sh <ip> <user> <pass> bootscript apply --script boot.ps1
```
`boot.ps1` (v1): start daemon, log boot event + OS build to `/DevFiles/`, ensure beacon to Mac. Full spec in `docs/08-persistence.md` (written in Phase 2).
Rollback: `wdp.sh ... bootscript clear`.

## Emergency / rollback
- Disable boot script → WDP API `unattendedsetup-default`.
- Leave Dev Mode → console returns to retail (all dev content wiped, settings reset).
- Factory reset (LAST resort — requires controller/app navigation): Settings → System → Console info → Reset console "Reset and remove everything".

## Known pitfalls
- Dev Mode auto-returns to retail after 15 min inactivity unless a UWP app is running — keep Dev Home or our app foregrounded during work.
- WDP self-signed cert → always `curl -k`.
- SMB from macOS: use SMB2/3; if mount fails, check WFP rules on console (see `docs/02` Solstice notes).

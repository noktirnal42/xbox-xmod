# USB NTFS Overrides (cold-boot file triggers) — Gen9/Series applicable

Source: https://xboxoneresearch.github.io/wiki/boot/usb-ntfs-overrides/ (retrieved 2026-10-12, page updated 2026-06-14)

Files/folders placed at the root of an **NTFS-formatted USB drive** that trigger operations during console **cold boot**. Several are explicitly Gen9 (Series X/S).

## High-interest for this project

| Path | Behavior | Interest |
|---|---|---|
| `$SystemUpdate\consoles.txt` | Console **writes its current OS build** to the file, plaintext | Harmless first test; version detection without network |
| `$DumpSystemOS` / `$DumpHostOS` / `$DumpGameOS` / `$DumpAll` | Console dumps OS **memory** to `$Diagnosis` on USB, chirps when done. Dump deleted-input flag. | Major: offline SystemOS memory access. Caveat: `.dmpx` files are **encrypted, retail key required** (UNVERIFIED whether header/metadata is still useful) |
| `$SystemUpdate\hwinit.cfg` | **Board-level overrides** (traces, voltages, clock — "console's BIOS options", magic `4E,49,57,48`, OC byte @0x8 range 0x01–0x58). Read, flashed, executed at cold boot. | Is it signature-checked? If not: a persistent *hardware*-level USB vector. UNVERIFIED — test carefully, bricking risk |
| `$SystemUpdate\devkit.ini` | Default debug interface, host network address, protocol — read+flashed at cold boot | Could redirect debug output to our Mac. UNVERIFIED on retail |
| `$Diagnosis\debug.bin` | "Hotplug Retail Debug (GodBox) capability certificate" — temporary retail debug boost | Needs a valid cert (we don't have one); note as mechanism |
| `$NoSurface` | Mounts external storage under **HostOS** (visible to `xcrdutil` in SystemOS, drive-lettered) | Storage path into HostOS view; harmless test |
| `$ConsoleRefresh` | Deletes `settings.xvd` at boot (== console refresh, keeps games) | Destructive-ish; useful reset tool, test last |
| `MSXB_Kiosk` (XVD file) | Kiosk-mode XVD on USB root boots console in kiosk mode | UNVERIFIED on Series retail |
| `$CopyPfmFile`, `$XpfmUseMe$`, `$HostEtwTrace`, `$Throttle` | Performance/ETW/trace logging to USB | Telemetry taps — could leak kernel/HostOS traces |

## Gen9-specific notes
- `$ConsoleGen9` / `$ConsoleGen9Lock`: region-lock toggles for Chinese consoles (Gen8 files do nothing on Series). Requires newer OS + Live connection.
- Region files deprecated since `10.0.19041.2493`.

## Caveats from wiki
- Some overrides **require devkit capability cert / `$SystemUpdate` / `$NoSurface` presence** to function.
- `$Dump*` folders are deleted by the console after use (one-shot).
- References to `$Diagnosis`, `$NoSurface`, `$DumpSystemOS`, `$DumpHostOS` exist in `xvdd.sys` (HostOS storage driver) — good static-analysis anchor.

## Our Phase 0 test ladder (safe → risky, each on own USB, console offline from Live)
1. `consoles.txt` (read-only probe of version) — SAFE
2. `$NoSurface` + benign marker files — SAFE
3. `$DumpSystemOS` → archive `.dmpx` even if encrypted — SAFE (read-only to console)
4. `$CopyPfmFile` / `$HostEtwTrace` — SAFE
5. `hwinit.cfg` with **stock-equivalent values only** first — CAUTION (brick risk until verified)
6. `devkit.ini` — CAUTION
7. `$ConsoleRefresh` — only when we want a settings wipe anyway

Operator runs each; agent documents in `recon/`.

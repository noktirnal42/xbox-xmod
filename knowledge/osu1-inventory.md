# OSU1 artifact inventory & differential analysis (2026-10-12)

Agent 03 run. Sources: 3 OSU1 packages (unzipped to `knowledge/osu1/extracted/<build>/`) + 2016 CDN XVDs.
Parser: `tools/xvd_parse.py` (struct per xvdtool `XVDStructs.cs`; signature 0x0–0x200, header 0x200–0x3000, magic `msft-xvd` @0x200 verified empirically).

## Build identity table
| OSU1 | Package version (all XVDs) | Build tag | Created | Patch note |
|---|---|---|---|---|
| latest | **9445.26100.0.32778** | 2026-09-27/28 | 2026-09 | console is .9438 → this OSU1 is the *next/upcoming* build |
| 1968 | 1968.26100.0.32778 | 2024-08-22 | 2024-08 | **Artifice fix** (24H2 bump) |
| 4910 | 4910.25398.0.32778 | 2024-07-11/12 | 2024-07 | **Collateral Damage fix** |

## Payload structure (all builds identical set)
`$SystemUpdate/`: `ScarlettHost.xvd` (Gen9 HostOS, 85 MB), `host.xvd` (Gen8 HostOS, 85 MB — same OSU1 serves both gens), `system.xvd` (1.5 GB, SystemOS), `systemaux.xvd` (2 GB), `systemauxf.xvd` (463–622 MB), `systemmisc.xvd` (2 GB), `systemtools.xvd` (64 MB), `all-langs.xvd` (4 GB), `SettingsTemplate.xvd` (**created 2013, unchanged since Xbox One launch**), `extfw.xvd` / `hddfw.xvd` / `nvmefw.xvd` (64 MB each, firmware payloads) + 33 language XVDs.

## Crypto status (blocks binary diff)
- Every XVD: `encrypted=True, signed=True`, retail ODK keyslot 0 (`hddfw`/`nvmefw` use keyslot 2 = RedOdk).
- xvdtool only *recognizes* ODK/CIK material by SHA-256 (`Keys/DurangoKeys.cs`) — the actual retail ODK bytes are not public; they live in SP-protected memory (extracted historically from console RAM via `DurangoKeyExtractor`, requires an escalated console — i.e. Phase 4 output).
- ⇒ **Offline static binary diff of OS internals is not possible yet.** Header-level facts only.

## Header-level diff results
- 4910 → 1968 → 9445: all package_version fields bump; no structural changes; SettingsTemplate.xvd byte-identical creation date across a decade.
- 4910 vs 1968 `systemauxf.xvd` drive size changed 622 → 463 MB (latest); systemauxf is the most *churning* small volume — candidate interest when we get file access.
- No empty/unencrypted XVD in any build (no easy entry).

## Where the binaries will actually come from (revised plan)
1. **Phase 1/3 console pulls**: WDP file API + SSH in dev mode → SystemOS binaries (`C:\Windows\System32\*`, drivers, services) → `knowledge/binaries/`. This is now the primary corpus source.
2. **OSU1 XVDs**: keep archived; if a future escalation ever recovers the retail ODK, these become decryptable offline (huge payoff, blocked today).
3. agents/04 target prioritization therefore shifts to **reachable-from-devmode surfaces** (xbdiagcap, devtoolslauncher, bootsh, WDP handlers, Sirep) rather than offline image analysis.

## Files
- `knowledge/osu1/extracted/{latest,1968,4910}/$SystemUpdate/*.xvd` (46 files each)
- `knowledge/artifacts/cdn-10.0.14393.2152/*.xvd` (8 files, 2016, incl. deltas_*.xvd)
- `knowledge/artifacts/xvd_info_emoose.md` (format narrative)

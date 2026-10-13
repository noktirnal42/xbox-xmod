# Firmware versions & OSU1 artifact registry

Source: xboxoneresearch wiki `operating-system/firmware/` (retrieved 2026-10-12). Latest OSU always at https://www.xbox.com/xboxone/osu1 (307→ download.microsoft.com/.../OSU1.zip).

## Key events on the timeline
- **10.0.25398.4910 (2024-07)** — patches **Collateral Damage** (Game Script UWP exec)
- **10.0.26100.1968 (2024-08)** — 24H2 bump; patches **Artifice** (devmode privesc)
- **10.0.26100.8866 (2026-07)** — **"SystemOS Privilege Escalation" patch** — i.e. a priv-esc existed publicly/in-the-wild as of mid-2026 (details unknown from this table; monitor for disclosure)
- Console runs **10.0.26100.9438** — newer than all rows in this table; next OSU will identify itself via `consoles.txt` USB probe or WDP.

## Downloaded artifacts (this repo)
| Path | Build | Size | Purpose |
|---|---|---|---|
| `knowledge/osu1/OSU1_latest_26100.xxxx.zip` | 26100.xxxx (2026-08 redirect) | 6.23 GB | current-firmware differential baseline |
| `knowledge/osu1/OSU1_10.0.26100.1968_artifice-patch.zip` | 26100.1968 | 7.24 GB | files MS touched to fix Artifice |
| `knowledge/osu1/OSU1_10.0.25398.4910-collateral-patch.zip` | 25398.4910 | 7.10 GB | files MS touched to fix Collateral Damage |
| `knowledge/artifacts/cdn-10.0.14393.2152/*.xvd` | 14393.2152 (2016) | ~4.0 GB | 8 XVDs (host/system/systemaux/updater/…) old baseline |

## Next step when downloads complete
1. Unzip OSU1s → contains XVDs + update files (per `file-formats/update-cfg`).
2. `xvdtool` (needs .NET; see `docs/05-lab-spec.md` Windows VM) to list inner file tables → extract binaries.
3. agents/03 diffs: binaries changed in .1968 vs .4911 (Artifice fix) and 4910 vs 4909 (Collateral fix) → touched-file target list.

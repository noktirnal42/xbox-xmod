# Update CDN (public, read-only) & firmware artifact collection

Source: xboxoneresearch wiki `xbox-live/update-cdn/` (retrieved 2026-10-12).

## Public endpoints (no auth required historically — UNVERIFIED current)
```
https://update-cdn.xboxlive.com/IsUpdateAvailable/<...>
https://update.xboxlive.com/IsUpdateAvailable/Batch
https://update.xboxlive.com/GetSpecificSystemVersion/<...>
https://update.xboxlive.com/GetSystemUpdatePackage/<...>
https://update.xboxlive.com/GetCacheGroupId
```
Plus `dlassets.xboxlive.com/public/content/dashboard/<build>/<...>.xvd` and `assets1.xboxlive.com/<n>/<guid>/<file>.xvd` direct downloads (old builds still up).

## Known-downloadable example builds (Xbox One era)
- `10.0.10586.1194`: ExtUpdater/SystemExt/Template2/ExtHost/systemaux/SystemTools/SystemExtMisc `.green.xvd`
- `10.0.14393.2152`: updater.xvd, system.xvd, host.xvd, systemaux/systemtools/systemmisc/settingstemplate + delta XVDs

## Use for us
1. **Baseline binary corpus** (older builds) → differential targets vs. current (Phase 3).
2. OSU1 offline package (current, from support.xbox.com — separate official channel) → `knowledge/osu1/`.
3. XVD format study material (`operating-system/xbox-virtual-drive` wiki page parsers).

## Rules
- GET only, unauthenticated. No API abuse (single fetches, no enumeration storms).
- Record URL + SHA256 + date for every artifact in `knowledge/artifacts/`.

# Agent 05 — Monitor Agent (live polling)

## Purpose
Watch public sources for new Xbox research, exploit disclosures, tool releases, and firmware changes; alert the operator with a digest.

## Mechanism
`tools/monitor_sources.sh` (committed in `tools/`):
- Fetches RSS/Atom feeds and GitHub listing pages (public, unauthenticated):
  - xboxoneresearch.github.io feed (blog)
  - GitHub repos: xboxoneresearch/*, exploits-forsale/* — latest commits/releases
  - xboxdevwiki recent changes
  - Microsoft Xbox support "OS version history" page (new firmware builds)
- Diffs against `knowledge/monitor/last_state.json`; writes `recon/YYYYMMDD_HHMM_monitor-digest.md` on change.

Schedule (operator installs once):
```bash
# launchd/cron every 6h:
0 */6 * * * cd /Volumes/Artificial_Intelligence_Machine_Learning/dev/Xbox_Xmod && tools/monitor_sources.sh >> recon/monitor.log 2>&1
```

## Hard scope
Public, unauthenticated, read-only endpoints only. Rate-limit: one fetch per source per run. No scraping behind logins.

## Digest format
```
# Monitor digest YYYY-MM-DD HH:MM
- [source] what changed (link)
- Assessment: does this affect our plan? (phases/docs to update)
- Action for operator: Y/N + what
```

## Triggers requiring immediate operator flag
1. New public Series X|S exploit/soft-mod claim → verify source before acting; update `docs/02` + plan.
2. New console firmware (OSU1 released) → snapshot & archive the package before the console updates (console stays offline until we have it).
3. Changes in xboxoneresearch tooling we depend on.

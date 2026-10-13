# Agent 02 — OSINT / Knowledge Agent

## Purpose
Harvest public Xbox research into `knowledge/`, structured so the binary-analysis and exploit-research agents can consume it.

## Sources (public, read-only)
- Xbox One Research wiki (xboxoneresearch.github.io) — every page listed in its nav: security/, boot/, operating-system/, development/, file-formats/
- xboxdevwiki.net (original Xbox — background methodology only)
- GitHub: `xboxoneresearch/*`, `exploits-forsale/*` (artifice, solstice), `xboxdev/*`
- Microsoft public docs: Device Portal API reference (learn.microsoft.com), UWP packaging docs
- Conference talks (YouTube): "Guarding Against Physical Attacks: The Xbox One Story" (PSSummit 2019, BlueHat 2019)

## Hard scope
Public read-only content only. No logging into anything. No fetching from authenticated endpoints.

## Procedure
1. For each source: extract technical claims (protocols, file formats, offsets, API endpoints, exploit mechanics) into one markdown file per topic in `knowledge/`, filename = topic (e.g., `wdp-api.md`, `xvd-format.md`).
2. Every claim gets a citation URL. No URL → mark `UNVERIFIED`.
3. Maintain `knowledge/INDEX.md`: one line per file (topic, last-updated date, 1-line summary).
4. When a page contradicts an existing note, keep both versions with dates and flag the conflict in INDEX.
5. Download any *artifacts* mentioned (tool repos, OSU1 files) only to `knowledge/artifacts/` with a `SOURCE.txt` noting origin URL and date.

## Deliverable per run
Updated `knowledge/INDEX.md` + new/updated notes + a short changelog at the top of INDEX (what changed this run).

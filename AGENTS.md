# AGENTS.md — rules for AI agents in this repo

## Mission
Support a research program against a single, user-owned Xbox Series X on a home LAN, culminating in persistent unsigned-code execution (soft-mod). Produce documentation, tooling, and analysis. Agents do NOT autonomously execute attacks; an operator reviews and runs anything touching the console.

## Hard scope limits
- Network targets: `192.168.1.0/24` only, and in practice only hosts the operator has identified as their own. Never scan, connect to, or enumerate anything else — not the WAN, not Microsoft infrastructure, not other ISPs/hosts.
- Microsoft cloud: only unauthenticated, public, read-only endpoints (e.g., the OS update CDN, public docs). No credential use, no token forging, no replay of Xbox Live traffic.
- Firmware exploitation work must be grounded in the operator's own console (dev-mode foothold) or in offline artifacts (OSU1 update packages, dumped binaries).
- No piracy tooling: no tools whose primary purpose is playing unlicensed copies of commercial games.

## Working conventions
- Everything lives in this repo. New findings → `knowledge/`, live scan output → `recon/` (timestamped filenames), new plans/specs → `docs/`.
- File naming: `YYYYMMDD_HHMM_<description>` for anything in `recon/`.
- Before proposing console interaction, write the exact commands into the relevant doc or `tools/` script and flag the operator. Prefer read-only operations.
- Never fabricate: offsets, ports, protocol details, or "known" vulnerabilities must cite a source (wiki page, CVE, blog post, or an artifact in `recon/`). If unknown, write "UNVERIFIED".
- Firmware version matters: tag all findings with the OS build they were observed on (e.g., `10.0.26100.xxxx`).

## Current project state
Phase 0 complete (offline prep); Phase 0 live recon pending console bring-up. Read `docs/09-findings-20261012.md` first — it consolidates everything known as of 2026-10-12, including which avenues are blocked (offline XVD decryption) and which are open. Then `docs/04-research-plan.md` for the phase list and `docs/06-devmode-playbook.md` for the active runbook. If the console IP is unknown, run `tools/discover_xbox.sh` first. Public mirror: https://github.com/noktirnal42/xbox-xmod

## Agent roster
Prompt specs live in `agents/`:
- `agents/01-recon-agent.md` — LAN/console discovery & fingerprinting
- `agents/02-osint-agent.md` — harvesting public research into `knowledge/`
- `agents/03-binary-analysis-agent.md` — triaging console binaries/updates
- `agents/04-exploit-research-agent.md` — vuln hypothesis & PoC planning
- `agents/05-monitor-agent.md` — live polling of public sources for new research

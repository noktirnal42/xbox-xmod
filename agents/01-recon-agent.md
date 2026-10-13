# Agent 01 — Recon Agent

## Purpose
Discover and fingerprint the operator's Xbox Series X on the home LAN; maintain a baseline of listening services in retail and dev mode.

## Tools
`tools/discover_xbox.sh`, `tools/xbox_portscan.sh`, `arp`, `dns-sd`, `nc`, `curl`.

## Hard scope
- `192.168.1.0/24` only. Only the console (and router if needed for DHCP info) is a target. Other discovered hosts are listed as "ignore" — never probed beyond the ARP entry.
- Read-only probes: SYN-level port checks, SSDP, mDNS, HTTP HEAD. No exploit payloads, no fuzzing, no brute force.

## Procedure
1. Run `tools/discover_xbox.sh`. Expect one host advertising Xbox-like traits (SSDP `Xbox-SystemOS` server string, mDNS entries, port profile per `docs/03-attack-surface.md` §A).
2. Record candidate → confirm with operator before anything beyond port scan.
3. Run `tools/xportscan.sh <ip>`; save to `recon/YYYYMMDD_HHMM_ports_<mode>.txt` (mode = retail|dev).
4. If ports 22/445/11443 open → console is in Dev Mode; tag findings accordingly.
5. Diff against previous scans; report new/closed ports as "surface change" events with timestamp + assumed firmware (ask operator to confirm build via Dev Home or WDP).

## Output format
Every session ends with a dated `recon/` file and a 5-line summary: IP, MAC, mode (retail/dev), open ports, anomalies. Never guess firmware version — UNVERIFIED unless read from the console.

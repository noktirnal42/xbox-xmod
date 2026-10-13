# xbox-xmod

**Research lab for Xbox Series X security & homebrew — documentation, methodology, and tooling.**

A structured, evidence-driven research program against a single operator-owned Xbox Series X on a home LAN. Goal: persistent homebrew code execution (soft-mod), built on the only sanctioned crack in the wall — Microsoft's own **Dev Mode** — and from there, honest vulnerability research toward deeper escape.

> **Status:** Phase 0 (offline prep complete; console bring-up in progress). See [`docs/09-findings-20261012.md`](docs/09-findings-20261012.md).

## Why this repo exists

There is no public soft-mod for Xbox Series X|S. Rather than a random pile of links, this is a **disciplined lab**: every claim cited, every console interaction scripted and reviewed, every phase producing artifacts the next researcher (human or AI agent) can pick up.

## The achievement ladder

| Rung | Outcome | Status |
|------|---------|--------|
| 1 | Console on LAN, fingerprinted, retail attack surface mapped | 🟡 in progress |
| 2 | **Dev Mode** foothold — Device Portal / SSH / SMB | documented |
| 3 | **Persistent dev-mode soft-mod** — boot-script persistence, auto-starting tooling | spec'd (`docs/08`) |
| 4 | SystemOS privilege escape (post-Artifice) | research targets listed |
| 5 | HostOS / hypervisor | open problem |

## Repository map

```
docs/    01-security-architecture   boot chain, hypervisor CI, XVD/XBFS, WFP
         02-current-state           full known-exploit history (2017→2026)
         03-attack-surface          LAN / USB / dev-mode surfaces
         04-research-plan           phased plan, milestones, risks
         05-lab-spec                hardware, network, tooling setup
         06-devmode-playbook        operator runbook
         07-uwp-deployment          getting our code onto the console
         08-persistence-spec        boot-script soft-mod design + test matrix
         09-findings-20261012       consolidated session findings
agents/  5 AI research-agent specs (recon, OSINT, binary analysis,
         exploit research, public-source monitoring)
tools/   discover_xbox.sh · xbox_portscan.sh · wdp.sh · usb_prep.sh
         monitor_sources.sh · xvd_parse.py
knowledge/  cited research notes: USB $-override triggers, Artifice autopsy,
         XVD/XBFS formats, firmware registry, OSU1 inventory, deep-link surface
```

## Highlights so far

- **USB `$`-override cold-boot triggers** cataloged (Gen9 memory dumps, build-version oracle, `hwinit.cfg` board config) with a safe→risky test ladder.
- **Artifice (2023) autopsy** distilled into a reusable devmode-privesc methodology and a 6-target re-analysis list.
- **XVD header format verified empirically**; all 46 payloads of three OSU1 firmware builds parsed and archived.
- Firmware timeline intel: a SystemOS privilege escalation was patched in **July 2026** — undisclosed; monitoring for disclosure.

## Ethics & scope (binding)

- Only the operator's **own console** on `192.168.1.0/24` is ever a target.
- Microsoft cloud: public, read-only endpoints only (update CDN, docs).
- Homebrew/interoperability research (cf. DMCA §1201 console exemption). **No piracy tooling** — nothing here plays unlicensed commercial games.
- Exploitation work is grounded in the operator's own dev-mode console or offline public artifacts. Nothing autonomous touches the console; a human runs everything.

## Getting started

```bash
git clone https://github.com/noktirnal42/xbox-xmod.git
cd xbox-xmod
./tools/discover_xbox.sh        # find the console on your LAN
./tools/xbox_portscan.sh <ip>   # map its surface
```

Read `AGENTS.md` before delegating any of this to AI agents, and `docs/06-devmode-playbook.md` before touching a console.

## License & attribution

Code and docs: MIT (see [LICENSE](LICENSE)). Research notes derive from the excellent [Xbox One Research wiki](https://xboxoneresearch.github.io/), [Kudayasu's Artifice autopsy](https://kudayasu.github.io/an-autopsy-of-artifice/), [emoose/xvdtool](https://github.com/emoose/xvdtool), and Microsoft's public documentation — all cited inline.

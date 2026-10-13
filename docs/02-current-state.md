# 02 — Current State: Known Exploits and What Still Applies

Source of record: https://xboxoneresearch.github.io/wiki/security/exploits/ (retrieved 2026-10-12).
All items below are **historical and presumed patched on current firmware (10.0.26100.xxxx)** — verify individually in Phase 2. Their value is as methodology and as a map of where the OS was weak.

## Retail-mode (no dev kit) — software

| Exploit | Year | Layer | Lesson for us |
|---|---|---|---|
| External VBI loading | 2019 | HostOS boot | Boot-stage selection logic was attackable; check if any removable-media boot selection remains |
| File Explorer symlink abuse | 2017 | SystemOS FS | XVD/volume permission checks had holes around symlinks |
| Edge chakra.dll info leak (CVE-2016-7200) | 2017 | SystemOS userland | Browser engine = classic RCE entry; current Edge is Chromium-based, new attack surface |
| Edge file system exposure | n/d | SystemOS sandbox escape | UWP broker bugs = sandbox escape class |
| WinJS injection via Xbox Live messaging | 2019 | SystemOS/dashboard | Messaging/parse surfaces reachable from network |
| ECC Curveball (CVE-2020-0601) | 2019 | Crypto/TLS | CryptoAPI trust-model bugs apply to any Windows-family OS; test against console's CryptoAPI build |
| Game Script UWP code exec ("Collateral Damage") | 2024 | UWP sandbox | **Most recent public retail UWP code-exec lineage**; study its post-exec steps |

## Dev-mode — privilege escalation (SystemOS sandbox → higher)

| Exploit | Year | Mechanism |
|---|---|---|
| VSProfiling account | 2018 | Weak service account credentials → elevated process launch |
| UnattendedUtilities | 2019 | Utilities run elevated with controllable inputs |
| System.xvd RW overlay | 2019 | Mount overlay to modify the OS volume itself |
| **Artifice** | 2023 | OpenSSH service vulnerability in dev mode → admin account in SystemOS (`admin`/`admin`); SYSTEM shell via `bootsh`→telnetd registry trick. **Patched 10.0.26100.1968 (2024-08-28) — our console (.9438) is past it.** See https://kudayasu.github.io/an-autopsy-of-artifice/ |

Dev-mode also grants: SSH/Sirep shell, SMB developer folder, full Device Portal API (including `unattendedsetup-apply` = **set a boot script that runs at every console boot** — the persistence primitive).

## Hardware

- **BLISS Hack** — hardware attack on boot chain (xboxoneresearch wiki). Out of scope for us (no soldering work planned) but note as fallback.

## What is publicly true in 2026

1. No public retail soft-mod for Series X|S on current firmware. The community's active line is Xbox One retail exploits + dev-mode tooling.
2. Series shares the OS lineage (Eden-era Windows Core OS) with One; many SystemOS attack classes carry over even if specific bugs are patched.
3. Dev-mode escalation history shows Microsoft patches these within OS updates — anything we test must be re-verified against the console's exact build (`os-machinename` / Xbox Info API reports it).

## Implications for our plan

- **Engineering phases (0–3)** are low-risk: recon, dev mode, WDP tooling, boot-script persistence.
- **Research phases (4–5)** should start where the historical exploits clustered: UWP brokers, service accounts/unattended infra, volume mounting (XVD/overlay), SSH/Sirep/WDP service code, browser/messaging parsers, CryptoAPI trust. All enumerable from inside dev mode.
- Differential analysis (old OSU1 packages vs. current) will show *which* files Microsoft touched when patching the known bugs — those files are proven-vulnerable-adjacent targets.

## References
- https://xboxoneresearch.github.io/wiki/security/exploits/
- https://github.com/exploits-forsale/artifice (Artifice)
- https://github.com/exploits-forsale/solstice (SystemOS tooling: WFP, persistence)

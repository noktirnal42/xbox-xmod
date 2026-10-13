# 01 — Xbox Series X Security Architecture

Status: verified against public sources (Xbox One Research wiki, Microsoft conference talks). Series-specific gaps marked UNVERIFIED.

## Hardware

- **SoC "Arden"**: custom AMD, 8-core Zen 2 + RDNA 2 (52 CU @ 1.825 GHz on Series X; 20 CU variant "Lockhart" for Series S). APU die includes the **Security Processor (SP)** (ARM) and the **SCP** (Streaming Crypto Processor, internal crypto engine).
- Series secure enclave codename **Sparkman** (xboxoneresearch wiki, `misc/codenames`). Details UNVERIFIED.
- **Boot media**: internal NVMe SSD (custom ASIC, PCIe 4.0 x2) — unlike Xbox One's eMMC + HDD. Southbridge still holds small flash for SMC/SBFS (UNVERIFIED for Series).
- Per-console secrets: eFuse-programmed keys inside the SP, never exposed to the x86 side (see Microsoft "Guarding Against Physical Attacks: The Xbox One Story", Platform Security Summit 2019 — youtube U7VwtOrwceo / BlueHat quLa6kzzra0).

## Boot chain (Xbox One documented; Series "differs slightly" per wiki)

```
SMC (southbridge)  : 0SMCBL (ROM) → 1SMCBL → 2SMCBL/SMCFW   [SBFS on flash]
SP (ARM)           : 0SP (ROM) → 1SP → 2SP                  [boot.bin, verified]
  SP decrypts/loads 2BL → x86 CPU
CPU                : 2BL → SCP init + keytable → Host VBI
HostOS             : host.xvd  (hypervisor + host kernel live here)
SystemOS           : system.xvd (the "Windows" OS the user sees)
TitleOS            : era.xvd / gamecore.xvd (per-game VM)
```

- **VBI** (Virtual Boot Image): final bootstrap stage; stored on flash (Host VBI) and on the OS volume (System VBI).
- **XBFS**: boot filesystem on the boot medium holding SP boot stages, VBI, certificates, bootanimation. Documented parser exists in xboxoneresearch tools.
- **SBFS**: southbridge filesystem (SMC stages, POST data).
- **XVD** (Xbox Virtual Drive): signed, encrypted container format for OS volumes and (as XVC) games. Dev-mode can mount/overlay XVDs in limited ways (see `docs/02` — System.xvd RW overlay exploit, patched).

## OS model

- A microtype of Windows Core OS ("Eden"/Scarlett-era). Three virtualized partitions talk over **XVIO** (Xbox Virtual Input/Output) message channels and ring buffers:
  - **HostOS** — hypervisor (hvax64) + host kernel; owns hardware, memory allocation, VM lifecycle, storage crypto.
  - **SystemOS** — dashboard, apps (UWP), services users can reach.
  - **TitleOS** — one VM per game (ERA/GameCore runtime).
- **Code Integrity (CI)**: enforced by the hypervisor — every page of kernel/user code in every partition must be signed; games run with per-title keys. On retail, no unsigned code executes anywhere; Dev Mode relaxes CI only for UWP packages deployed to the dev sandbox in SystemOS.
- **Device identity**: per-console certs + SP-held keys; console certificates chain to Microsoft retail PKI. The wiki `security/certificates` page documents the cert chain for Xbox One.

## Network posture (retail)

- Windows **WFP firewall** on SystemOS with profiles (domain/private/public); inbound default-deny outside a small set. Wiki `operating-system/firewall` notes port opening requires disabling profiles + creating WFP rules (see `exploits-forsale/solstice` for example code).
- Retail listening surface (to be confirmed live by `tools/xbox_portscan.sh`): SSDP/UPnP (UDP 1900), mDNS (UDP 5353), Xbox Live rendezvous ports (3074 TCP/UDP, 88 UDP), possibly HTTP services in the 1025–1050 range (UNVERIFIED on retail Series).
- Dev Mode adds: WDP HTTPS **11443**, SSH **22**, SMB **445** (developer folder), Sirep (UNVERIFIED port, typically 1025 family) — all bound to the dev sandbox.

## What this means for the project

1. Every path to persistent unsigned code without Dev Mode crosses the SP→2BL→VBI chain or the hypervisor CI — no public shortcut on Series.
2. Dev Mode is the sanctioned crack in the wall: signed-by-us UWP code executes in SystemOS, with documented historical escapes (all patched) and a documented **persistence primitive** (`unattendedsetup-apply` boot script).
3. Therefore: rung 1–3 of the goal ladder (recon → devmode → persistent devmode soft-mod) are engineering; rungs 4–5 are genuine vuln research against SystemOS↔HostOS boundaries (XVIO, WFP, SMB/Sirep/WDP handlers, parser surfaces).

## Sources
- https://xboxoneresearch.github.io/wiki/boot/bootloaders/
- https://xboxoneresearch.github.io/wiki/security/general-security-design/
- https://xboxoneresearch.github.io/wiki/security/security-processor/
- https://xboxoneresearch.github.io/wiki/misc/codenames/ (Arden/Sparkman)
- https://xboxoneresearch.github.io/wiki/operating-system/firewall/
- Microsoft PSSummit 2019 talk (above).

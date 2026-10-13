# XVD format & XBFS (boot flash) internals

Sources: xboxoneresearch wiki `operating-system/xbox-virtual-drive/`, `boot/xbox-boot-file-system/` (retrieved 2026-10-12).

## XVD (Xbox Virtual Drive)
- Secured container; XVD = system images/data, XVC = games (slight variant).
- Layout: header (0x0–0x200, **signed by Microsoft key**) → optional embedded XVD (e.g. GameOS) → optional SHA-256 hash tree (hashes truncated to 0x18h bytes) → optional Persistent Local Storage → optional XVC descriptor (first 3 blocks of XVC, never encrypted: content ID, encryption keys, chunk updates, region offsets/keys) → data → inner filesystem = **NTFS**.
- Integrity: multi-level hash tree → top hash in header; header hash is signed. Same idea as 360 STFS with consolidated tables.
- Encryption: data blocks **AES-XTS** (region ID included in IV/data-unit). FS data encrypted with **CIK** (Content Instance Key):
  - Non-XVC: CIK stored encrypted in header with **ODK** (Offline Distribution Key; appears static across XVDs, differs retail vs devkit).
  - XVC: key fetched from Live or disc; seemingly obfuscated (possibly ODK-wrapped).
- Tools: **xvdtool** (emoose) — parse/extract; XVD format PDF on wiki.
- Attack relevance: this is the format of `system.xvd`, `host.xvd`, `settings.xvd`, update deltas, OSU1 contents. The System.xvd RW-overlay exploit (2019) abused dev-mode mount paths into this format.

## XBFS (boot flash filesystem) — Series S/X specifics
- Series: XBFS lives in a **dedicated NVMe section**, logical size 0x40000000 (1 GB). Durango-era eMMC XBFS = 5056 MB raw.
- Header magic `SFBX`; bootslot A @ 0x0, B @ 0x18008000 (Durango: A 0x10000, B 0x810000, C 0x820000). 3 filetables, highest sequence number wins (seq wraps 0xFF→0x00; 0x00 is latest).
- Header 0x400 bytes: magic(4) fmt ver(1) seq ver(1) layout ver(2) unknowns(3×8) → 58×XBFS_FILE_ENTRY(0x10: u32 offset_pages, u32 size_pages, u64 unk) → UUID(0x10) + SHA256(0x20).
- **Series quirk: subtract 0x6000 from computed file start offset.**
- Entry names (fw 10.0.10586.1029): `1smcbl_a/b.bin`, `boot.bin`, `host.xvd`, `system.xvd`, `$sospf.xvd` (restore), `settings.xvd`, `certkeys.bin`, `sp_s.cfg`/`sp_d.cfg`/`os_s.cfg`/`os_d.cfg` (XConfig), `smcfw.bin`, `hwinit.cfg`, `devkit.ini`, `update.cfg`/`update2.cfg`, `bootanim.dat`, `qaslt.xvd`, etc.
  - Note: `hwinit.cfg` and `devkit.ini` exist in flash too — the USB `$SystemUpdate\` overrides interact with these (see `usb-ntfs-overrides.md`).
  - Per-console encrypted/locked files: certkeys.bin, sp_s.cfg (SoCId lock).

## Access from SystemOS (dev-mode/elevated)
- `\\.\Xvuc\FlashFs\` — NTFS-filtered view of flash (normal Win32 file APIs; e.g. read `sp_s.cfg`)
- `\\.\Xvuc\Flash\` — raw flash access, no filter
- **QuantumTunnel** (github.com/XboxOneResearch/QuantumTunnel): .NET Core XBFS dumper, needs Administrator/NT SYSTEM in SystemOS → depends on an escalation. Other tools: xvdtool, xbfs-tool (C, parse/inject).

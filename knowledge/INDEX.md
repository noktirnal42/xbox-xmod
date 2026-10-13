# Knowledge Index

| File | Topic | Updated | Summary |
|---|---|---|---|
| `usb-ntfs-overrides.md` | USB cold-boot triggers | 2026-10-12 | `$`-files on NTFS USB trigger boot ops incl. Gen9 memory dumps, hwinit.cfg board overrides, kiosk XVD boot; test ladder inside |
| `devmode-access.md` | Dev mode foothold | 2026-10-12 | SSH `DevToolsUser` (VS-pin or WDP password), SMB, WDP endpoints; Artifice **patched** in 10.0.26100.1968; `bootsh`→SYSTEM technique |
| `update-cdn.md` | Firmware artifacts | 2026-10-12 | Public update endpoints; old-build XVD downloads for differential analysis |
| `artifice-autopsy.md` | Devmode privesc methodology | 2026-10-12 | Full Artifice chain: xbdiagcap junction read, WDP loose-folder junction write, devtoolslauncher, sshd AuthorizedKeysCommand, bootsh→SYSTEM; Phase 3/4 target list |
| `xvd-xbfs-formats.md` | XVD/XBFS formats | 2026-10-12 | XVD header/hash-tree/AES-XTS/CIK-ODK; XBFS Gen9 offsets, 58 entries, `\\.\Xvuc\FlashFs\` pipe, QuantumTunnel/xvdtool |
| `storage-and-uris.md` | Storage + deep links | 2026-10-12 | NVMe partition GUIDs, USB `99 CC` marker, full protocol-URI list (systemupdatenew://, ms-oobe://, etc.) |
| `firmware-registry.md` | Firmware versions + artifacts | 2026-10-12 | OSU1 URL pattern; July-2026 priv-esc patch note; 3 OSU1 zips (latest, Artifice-patch, Collateral-patch) + 8 old-build XVDs downloading |
| `osu1-inventory.md` | OSU1/XVD analysis | 2026-10-12 | All 3 OSU1s unzipped + parsed; XVD header format verified; retail ODK absent ⇒ offline binary diff blocked; corpus source shifts to console pulls in dev mode |

## Changelog
- 2026-10-12: initial harvest (agents/02 run): usb-ntfs-overrides, devmode-access/artifice, update-cdn.
- 2026-10-12 (2): artifice-autopsy, xvd-xbfs-formats, storage-and-uris added. OSU1 URL still unlocated (JS page) — operator to download manually from support.xbox.com.
- 2026-10-12 (3): OSU1 located via wiki firmware table; 3 OSU1 zips + 8 CDN XVDs downloading to knowledge/. Diff plan in firmware-registry.md.
- 2026-10-12 (4): downloads complete, unzipped, parsed (agents/03 run). See osu1-inventory.md.

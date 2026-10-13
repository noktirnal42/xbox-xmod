# Storage layout (NVMe/external) & protocol URI surface

Sources: xboxoneresearch wiki `operating-system/harddrive-partitioning/`, `operating-system/protocol-URIs/` (retrieved 2026-10-12).

## Internal NVMe partitioning (GPT, NTFS)
| Partition | GUID | Size |
|---|---|---|
| Temp Content | B3727DA5-A3AC-4B3D-9FD6-2EA54441011B | 41 GB |
| User Content | variable (size-dependent GUID) | — |
| System Support | C90D7A47-CCB9-4CBA-8C66-0459F6B85724 | 40 GB |
| System Update | 9A056AD7-32ED-4141-AEB1-AFB9BD5565DC | 12 GB |
| System Update 2 | 24B2197C-9D01-45F9-A8E1-DBBCFA161EB2 | 7 GB |
(User Content GUIDs: 500GB A2344BDB-…, 1TB 25E8A1B2-…, 2TB 5B114955-…)

## External USB storage
- App/game storage drives: USB 3.0, ≥128 GB, GPT+NTFS, **custom boot signature `99 CC` @ 0x1FE** (vs standard `55 AA`) → unreadable on PC until overwritten. (Overwriting the signature makes it mountable on the Mac — useful for reading console-formatted experiment drives later.)

## Protocol URIs (deep links) — full list as of 10.0.19041.6630
Harvested by the wiki from appx manifests via a dev-mode admin account. Notable entries:
- `ms-settings://`, `settings://` (Xbox Settings), `ms-oobe://`, `oobe://` (OOBE), `signin://`, `systemupdatenew://` (Xbox.SU), `ms-device-enrollment://`, `ms-cxh://` (CloudExperienceHost), `ntscaptiveportal://`
- `ms-xdash://`, `guide://`, `xbox-gamehub://`, `ms-windows-store://`, `microsoft-edge://`, `read://`
- Debug/dev: `ms-xbl-1c835833://` (DevHome)
Full table in the wiki page; use `docs/experiments/` runs to test which launch from our UWP app (`Launcher.LaunchUriAsync`) and which accept attacker-influenced params (classic parser/deep-link attack surface).

## Relevance
- Deep-link surface = launchable-from-our-app system components (Phase 4 target class 5).
- Partition GUIDs let us map any raw volume images we later obtain.
- `99 CC` marker: remember when examining console-formatted USB drives.

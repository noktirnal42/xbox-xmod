# 07 — UWP Deployment from macOS (Phase 1)

Goal: get our own signed code running on the console. Reference: xboxoneresearch `development/deploying-uwp-apps/`, `development/setup-dev-mode/`, Artifice autopsy (`knowledge/artifice-autopsy.md`).

## Path A — Windows VM (reliable, recommended first)
1. Install UTM or Parallels; Windows 11; install Xbox GDK tooling or just the UWP SDK bits.
2. Use `XboxWdpDriver` (github.com/microsoft/WindowsDevicePortalWrapper) — handles CSRF automatically:
   ```
   XboxWdpDriver.exe /x:<console-ip> /op:install /appx:hello.msix /u:<wdp-user> /p:<wdp-pass>
   XboxWdpDriver.exe /x:<ip> /op:loosefolderregister /folder:<path> ...
   ```
3. `winappdeploycmd` also works (device discovery via Sirep/IpOverUsb/mDNS).

## Path B — pure macOS (no Windows)
WDP is plain HTTPS+Basic-auth; packaging is the only Windows-flavored part.
1. **Package**: .msix/.appx is OPC (zip) + `AppxManifest.xml` + `[Content_Types].xml` → buildable with `zip` on macOS. Manifest needs `Package/Identity` matching a self-signed cert.
2. **Sign**: create self-signed code-signing cert (`openssl`), then sign... Authenticode signing without Windows tools is the hard part. Options: `osslsigncode` (brew) supports Authenticode for PE; for Appx, signature is inside `AppxSignature.p7x`. UNVERIFIED whether WDP Xbox accepts `osslsigncode`-produced Appx signatures — TEST in Phase 1; fallback = Path A.
3. **Trust**: console must trust our cert → add cert via WDP `/api/app/trust` (UNVERIFIED exact endpoint; verify against MS Device Portal docs) or Dev Home.
4. **Deploy via WDP REST** (our `tools/wdp.sh`):
   - `POST /api/app/packagemanager/package` (install uploaded package)
   - `POST /api/app/packagemanager/upload` (push files)
   - `POST /api/ext/app-packagemanager/era-register` style ext endpoints for loose folders
5. **Launch**: `POST /api/taskmanager/app` with PFN/AUMID, or `XboxWdpDriver /op:launch`.

## Minimal hello-world spec (Phase 1 first artifact)
- C# UWP "blank app" or packaged C++ Win32 (full-trust in dev sandbox?) — start with plain UWP, no elevation.
- On launch: write `/DevFiles/xmod-hello.txt` with timestamp + build number; exit. Verifies: deployment, execution, FS write, build reporting.

## Artifice's reusable deployment facts (from autopsy)
- Loose-folder deployment endpoint + `/transfer:HTTP` routes through WDP.
- Launch needs PFN + AUMID.
- Dev scratch = `D:\DevelopmentFiles` (SMB-mappable).

## Open items (resolve in Phase 1)
- [ ] Exact WDP install endpoints + payload format (fetch MS Device Portal docs)
- [ ] macOS Authenticode/Appx signing viability (osslsigncode)
- [ ] Whether full-trust packaged apps are allowed in dev mode on Series

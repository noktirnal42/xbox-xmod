# Agent 03 — Binary Analysis Agent

## Purpose
Triage console binaries and update packages into a ranked target list for Phase 4 vulnerability research.

## Inputs
- Binaries pulled from the console via WDP/SSH (Phase 3) → `knowledge/binaries/`
- OSU1 offline update packages (public CDN) → `knowledge/osu1/`
- Notes from `agents/02`.

## Hard scope
Offline static analysis only. No execution of console code on this Mac (unknown x64 PE — analyze, don't run). No distribution of dumps.

## Tooling (macOS)
- `strings`, `otool`-equivalent for PE = **`objdump`/`llvm-objdump`** (Xcode CLT), `nm` (PE symbol tables when present)
- python3 + `pefile` (`pip3 install pefile pycryptodome`) for PE/PE32+ parsing, import tables, version resources
- SBFS/XBFS parsers: reference xboxoneresearch tool repos in `knowledge/artifacts/`

## Procedure
1. **Inventory**: for each artifact — PE header, architecture, imports (crypto? network? named-pipe/RPC? file?), version resource, signing cert (check against wiki `security/certificates`).
2. **Classify** by attack class from `docs/02-current-state.md`: broker/service, mounting/XVD, network-listening service (WDP/Sirep/SMB/SSH), parser, crypto/trust.
3. **Rank** targets: (reachability from dev-mode SystemOS) × (similarity to historical vuln classes) × (churn — does it change between builds?).
4. **Differential**: when two builds of the same binary exist, list changed sections/imports; churn near known-patched code = high-interest.
5. Emit `knowledge/targets.md`: ranked table — binary, class, reachability, why interesting, next analysis step.

## Output discipline
Every claim cited to a file+section in `knowledge/binaries/` or a tool output in `recon/`. Unknown = UNVERIFIED. No exploit code in this agent — analysis only.

#!/usr/bin/env python3
"""xvd_parse.py — XVD header parser (per xvdtool LibXboxOne/XVD/XVDStructs.cs + empirical checks).
Usage: xvd_parse.py <file.xvd> [more.xvd ...]   → JSON per file (stdout) or --table for summary.
File layout: 0x0-0x200 RSA signature area, 0x200-0x3000 header. Struct offsets +0x200.
"""
import struct, sys, json, hashlib
from datetime import datetime, timedelta

HDR = 0x200

def parse(path):
    out = {"path": path}
    with open(path, "rb") as f:
        d = f.read(0x3000)
    if len(d) < 0x3000:
        out["error"] = f"file too small ({len(d)})"
        return out
    out["magic"] = d[HDR:HDR+8].decode("ascii", "replace")
    if out["magic"] != "msft-xvd":
        out["error"] = "not an XVD"
        return out
    flags = struct.unpack_from("<I", d, HDR+0x08)[0]
    flag_names = ["ReadOnly","EncryptionDisabled","DataIntegrityDisabled","LegacySectorSize",
                  "ResiliencyEnabled","SraReadOnly","RegionIdInXts","EraSpecific"]
    out["volume_flags"] = hex(flags)
    out["flags"] = [n for i, n in enumerate(flag_names) if flags >> i & 1]
    out["encrypted"] = "EncryptionDisabled" not in out["flags"]
    out["format_version"] = struct.unpack_from("<I", d, HDR+0x0C)[0]
    ft = struct.unpack_from("<q", d, HDR+0x10)[0]
    try:
        out["created"] = (datetime(1601,1,1) + timedelta(microseconds=ft//10)).isoformat()
    except Exception:
        out["created"] = "invalid"
    out["drive_size_mb"] = struct.unpack_from("<Q", d, HDR+0x18)[0] // (1024*1024)
    out["vduid"] = d[HDR+0x20:HDR+0x30].hex()
    out["type"] = struct.unpack_from("<I", d, HDR+0x80)[0]
    out["content_type"] = struct.unpack_from("<I", d, HDR+0x84)[0]
    out["embedded_xvd_len"] = struct.unpack_from("<I", d, HDR+0x88)[0]
    out["userdata_len"] = struct.unpack_from("<I", d, HDR+0x8C)[0]
    out["xvc_data_len"] = struct.unpack_from("<I", d, HDR+0x90)[0]
    out["block_size"] = hex(struct.unpack_from("<I", d, HDR+0x98)[0])
    out["sandbox_id"] = d[HDR+0x18C:HDR+0x19C].decode("ascii","replace").rstrip("\x00")
    out["product_id"] = d[HDR+0x19C:HDR+0x1AC].hex()
    out["pduid_buildid"] = d[HDR+0x1AC:HDR+0x1BC].hex()
    v = struct.unpack_from("<4H", d, HDR+0x1BC)
    out["package_version"] = ".".join(map(str, v))
    rv = struct.unpack_from("<4H", d, HDR+0x294)
    out["required_system_version"] = ".".join(map(str, rv))
    out["odk_keyslot"] = struct.unpack_from("<I", d, HDR+0x29C)[0]
    out["sequence_number"] = struct.unpack_from("<q", d, HDR+0x28C)[0]
    sig = d[0:HDR]
    out["signed"] = any(sig[0x20:])
    import os
    out["file_size"] = os.path.getsize(path)
    out["sha256_head0x3000"] = hashlib.sha256(d).hexdigest()[:16]
    return out

if __name__ == "__main__":
    args = sys.argv[1:]
    table = "--table" in args
    files = [a for a in args if a != "--table"]
    rows = [parse(p) for p in files]
    if table:
        cols = ["path","magic","package_version","required_system_version","encrypted","signed",
                "drive_size_mb","content_type","sandbox_id","odk_keyslot","created","sha256_head0x3000"]
        print("\t".join(cols))
        for r in rows:
            print("\t".join(str(r.get(c, "")) for c in cols))
    else:
        print(json.dumps(rows, indent=1))

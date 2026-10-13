#!/bin/zsh
# usb_prep.sh — build an NTFS image with the "$-override" test tree (knowledge/usb-ntfs-overrides.md)
# macOS can't write NTFS natively → we build a raw disk image with mkntfs (ntfs-3g), then the
# operator dd's it to a USB drive. NEVER run dd against a drive without confirming the device.
set -u
STAGE="$(dirname "$0")/../recon/usb_stage"
IMG="$STAGE/xmod_usb.img"
MNT="$STAGE/mnt"
SIZE_MB="${1:-512}"
mkdir -p "$STAGE"

# --- build the override tree (plain files on a staging dir first) ---
TREE="$STAGE/tree"; rm -rf "$TREE"; mkdir -p "$TREE"
mkdir -p "$TREE/\$SystemUpdate"
echo "" > "$TREE/\$SystemUpdate/consoles.txt"          # T1: console writes build version (SAFE)
mkdir -p "$TREE/\$NoSurface"                            # T2: HostOS-mounted volume (SAFE)
touch "$TREE/\$NoSurface/XMOD_MARKER_$(date +%s)"
mkdir -p "$TREE/\$DumpSystemOS"                         # T3: SystemOS memory dump (SAFE, encrypted out)
mkdir -p "$TREE/\$DumpHostOS"                           # T4: HostOS memory dump (read-only to console)

echo "[*] Staged tree:"
find "$TREE" -print

# --- build NTFS image ---
if ! command -v mkntfs >/dev/null 2>&1; then
  echo "[!] mkntfs not found. Install: brew install ntfs-3g  (then re-run)" >&2
  exit 1
fi
rm -f "$IMG"
dd if=/dev/zero of="$IMG" bs=1m count=$((SIZE_MB)) status=none
mkntfs -Q -F -L XMOD "$IMG"
mkdir -p "$MNT"
# mount image read-write via ntfs-3g (macFUSE required) and copy tree
if command -v ntfs-3g >/dev/null 2>&1; then
  ntfs-3g "$IMG" "$MNT" -o auto_xattr || exit 1
  cp -R "$TREE/" "$MNT/"
  umount "$MNT"
  echo "[+] NTFS image ready: $IMG"
  echo "    Next (OPERATOR): diskutil list  →  confirm USB disk N  →  diskutil unmountDisk diskN"
  echo "    sudo dd if=$IMG of=/dev/rdiskN bs=1m"
else
  echo "[!] ntfs-3g not installed (macFUSE). Image created but EMPTY copy skipped."
  echo "    Alternative: format the USB on a Windows PC and copy $TREE contents."
fi

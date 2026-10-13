#!/bin/zsh
# discover_xbox.sh — find the Xbox Series X on the local LAN (192.168.1.0/24)
# Read-only: ARP sweep + SSDP probe + TCP port fingerprint. Scope: local subnet only.
set -u
SUBNET="192.168.1"
OUTDIR="$(dirname "$0")/../recon"
mkdir -p "$OUTDIR"
STAMP="$(date +%Y%m%d_%H%M)"
OUT="$OUTDIR/${STAMP}_discovery.txt"

echo "# Xbox discovery $(date)" | tee "$OUT"

# 1) ARP sweep (backgrounded pings, then read ARP table)
for i in $(seq 1 254); do (ping -c 1 -W 100 "$SUBNET.$i" >/dev/null 2>&1 &); done
sleep 6
HOSTS=$(arp -a -n | grep -v incomplete | awk '{print $2}' | tr -d '()' | grep "^$SUBNET\." | sort -V)
echo "[*] Live hosts:" | tee -a "$OUT"
echo "$HOSTS" | tee -a "$OUT"

# 2) SSDP probe (Xbox replies with Server: ... / Xbox-SystemOS)
echo "[*] SSDP probe..." | tee -a "$OUT"
SSDP_OUT=$( (printf 'M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: "ssdp:discover"\r\nMX: 3\r\nST: ssdp:all\r\n\r\n' ; sleep 4) | nc -u -w 5 239.255.255.250 1900 2>/dev/null )
echo "$SSDP_OUT" >> "$OUT" 2>/dev/null || true
echo "$SSDP_OUT" | grep -qi "xbox" && echo "[+] SSDP mentions Xbox" | tee -a "$OUT"

# 3) Fingerprint candidates: Xbox-typical TCP ports
for ip in ${(f)HOSTS}; do
  [ "$ip" = "$(ipconfig getifaddr en0)" ] && continue
  OPEN=""
  for p in 3074 1025 11443 22 445 80; do
    nc -z -G 1 "$ip" "$p" 2>/dev/null && OPEN="$OPEN $p"
  done
  # SSDP search response for this host would name it; print what we know
  echo "[?] $ip open_tcp:${OPEN:-none}" | tee -a "$OUT"
done

echo "[*] Done. Review $OUT — confirm the console with the operator before further probing." | tee -a "$OUT"

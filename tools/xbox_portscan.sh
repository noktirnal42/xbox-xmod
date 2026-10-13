#!/bin/zsh
# xbox_portscan.sh <ip> — TCP/UDP surface map of the console (read-only probes)
# Usage: xbox_portscan.sh 192.168.1.x [retail|dev]
set -u
IP="${1:?usage: xbox_portscan.sh <ip> [mode]}"
MODE="${2:-unknown}"
OUTDIR="$(dirname "$0")/../recon"; mkdir -p "$OUTDIR"
STAMP="$(date +%Y%m%d_%H%M)"
OUT="$OUTDIR/${STAMP}_ports_${MODE}.txt"

TCP_PORTS="21 22 53 80 443 445 554 1025 1026 1027 1028 1029 1030 1035 1040 1041 1042 1043 11443 1900 2869 3074 32764 47001 49152 49153 5357 8080 9090"
UDP_PORTS="53 88 123 1900 3074 3544 4500 5050 5353"

echo "# Port scan $IP mode=$MODE $(date)" > "$OUT"
echo "[*] TCP sweep of $IP..." | tee -a "$OUT"
for p in ${(z)TCP_PORTS}; do (nc -z -G 1 "$IP" "$p" 2>/dev/null && echo "TCP $p OPEN" >> "$OUT") & done
wait
echo "[*] UDP probe (best-effort; UDP 'open' needs svc-specific payloads)..." | tee -a "$OUT"
for p in ${(z)UDP_PORTS}; do (nc -z -u -G 1 "$IP" "$p" 2>/dev/null && echo "UDP $p responded" >> "$OUT") & done
wait

# HTTPS fingerprint of WDP if open
if grep -q "TCP 11443 OPEN" "$OUT"; then
  echo "[*] 11443 open → Dev Mode likely. WDP fingerprint:" | tee -a "$OUT"
  curl -sk -I --max-time 5 "https://$IP:11443/" >> "$OUT" 2>&1
  curl -sk --max-time 5 "https://$IP:11443/" | head -c 400 >> "$OUT" 2>&1
fi
# HTTP fingerprint of 80/1025+ if open
for p in 80 1025 1026 1027 1028 1029 1030; do
  if grep -q "TCP $p OPEN" "$OUT"; then
    echo "[*] HTTP probe port $p:" | tee -a "$OUT"
    curl -s -I --max-time 5 "http://$IP:$p/" | head -15 >> "$OUT" 2>&1
  fi
done
grep -E "OPEN|responded|Server:|Xbox|Dev" "$OUT" | tee -a "$OUT"
echo "[*] Saved: $OUT"

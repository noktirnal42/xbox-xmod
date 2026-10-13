#!/bin/zsh
# monitor_sources.sh — poll public sources for new Xbox research / firmware (agents/05)
# Public, unauthenticated, read-only. One fetch per source per run.
set -u
ROOT="$(dirname "$0")/.."
OUTDIR="$ROOT/recon"; STATEDIR="$ROOT/knowledge/monitor"
mkdir -p "$OUTDIR" "$STATEDIR"
STAMP="$(date +%Y%m%d_%H%M)"
STATE="$STATEDIR/last_state.json"
DIGEST="$OUTDIR/${STAMP}_monitor-digest.md"
CHANGED=0

echo "# Monitor digest $(date)" > "$DIGEST"

check() { # name url
  local name="$1" url="$2" key hash
  hash=$(curl -sL --max-time 20 "$url" | shasum -a 256 | awk '{print $1}')
  key=$(python3 -c "
import json,sys,os
p=sys.argv[1]; k=sys.argv[2]
d=json.load(open(p)) if os.path.exists(p) else {}
print(d.get(k,''))" "$STATE" "$name" 2>/dev/null)
  if [ "$hash" != "$key" ]; then
    CHANGED=1
    echo "- [CHANGE] $name — $url" >> "$DIGEST"
  else
    echo "- [ok] $name" >> "$DIGEST"
  fi
  python3 -c "
import json,sys,os
p=sys.argv[1]; k=sys.argv[2]; v=sys.argv[3]
d=json.load(open(p)) if os.path.exists(p) else {}
d[k]=v; json.dump(d,open(p,'w'),indent=1)" "$STATE" "$name" "$hash" 2>/dev/null
}

check "xboxoneresearch-blog" "https://xboxoneresearch.github.io/feed.xml"
check "wiki-exploits"       "https://xboxoneresearch.github.io/wiki/security/exploits/"
check "wiki-recent"         "https://xboxoneresearch.github.io/wiki/recent-changes/"
check "gh-exploits-forsale" "https://github.com/orgs/exploits-forsale/repositories"
check "gh-xboxoneresearch"  "https://github.com/orgs/xboxoneresearch/repositories"
check "ms-osu1-history"     "https://support.xbox.com/help/hardware-network/console/system-updates-solutions"

if [ "$CHANGED" -eq 1 ]; then
  echo "- Action: review changed sources; update docs/knowledge as per agents/05." >> "$DIGEST"
fi
echo "digest: $DIGEST (changes: $CHANGED)"

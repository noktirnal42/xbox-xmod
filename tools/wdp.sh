#!/bin/zsh
# wdp.sh — minimal Xbox Device Portal (WDP) client for the console
# Usage:
#   wdp.sh <ip> <user> <pass> info
#   wdp.sh <ip> <user> <pass> processes
#   wdp.sh <ip> <user> <pass> packages
#   wdp.sh <ip> <user> <pass> get <remote-path> <local-file>
#   wdp.sh <ip> <user> <pass> put <local-file> <remote-folder>
#   wdp.sh <ip> <user> <pass> bootscript apply <script.ps1>   # Phase 2 persistence
#   wdp.sh <ip> <user> <pass> bootscript show|clear
# API endpoints per xboxoneresearch wiki (development/dev-portal-api/*) + MS docs.
set -u
IP="${1:?}"; USER="${2:?}"; PASS="${3:?}"; CMD="${4:?}"; shift 4
BASE="https://$IP:11443/api"
AUTH="$USER:$PASS"
C="curl -sk --max-time 15 -u $AUTH"

case "$CMD" in
  info)        $C "$BASE/os/machinename" && echo && $C "$BASE/os/info" ;;
  processes)   $C "$BASE/resourcemanager/processes" ;;
  packages)    $C "$BASE/appx/packagemanager/packages" ;;
  get)         $C -o "${3:?local file}" "$BASE/filesystem/files?path=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "${2:?remote path}")" ;;
  put)         $C -X POST -F "file=@${2:?local file}" "$BASE/filesystem/files?path=$(python3 -c "import urllib.parse,sys;print(urllib.parse.quote(sys.argv[1]))" "${3:?remote folder}")" ;;
  bootscript)
    case "${1:-}" in
      apply) $C -X POST -F "script=@${2:?ps1 file}" "$BASE/ext/unattendedsetup/apply" ;;
      show)  $C "$BASE/ext/unattendedsetup/default" ;;
      clear) $C -X POST "$BASE/ext/unattendedsetup/apply" -d '' ;;
      *) echo "bootscript apply <file> | show | clear" ;;
    esac ;;
  *)
    echo "unknown cmd: $CMD" ;;
esac
# NOTE: endpoint paths follow the xboxoneresearch wiki; if a call 404s, verify
# exact path against knowledge/wdp-api.md before retrying (agents/02 maintains it).

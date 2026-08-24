#!/usr/bin/env bash
# wait-for-conn.sh
# Usage: wait-for-conn.sh -i IFACE [-t TIMEOUT_SECONDS] [-s SLEEP_SECONDS] [-q]
# Returns 0 when connected, 1 on timeout or error.

set -u

usage() {
  cat <<EOF
Usage: $0 -i IFACE [-t TIMEOUT_SECONDS] [-s SLEEP_SECONDS] [-q]
  -i IFACE    Network interface to check (required)
  -t TIMEOUT   Timeout in seconds (optional; default: 0 => wait forever)
  -s SLEEP     Sleep interval between checks in seconds (default: 1)
  -q           Quiet (less output)
EOF
  exit 2
}

IFACE=""
TIMEOUT=0
SLEEP=1
QUIET=0

while getopts "i:t:s:q" opt; do
  case "$opt" in
    i) IFACE="$OPTARG" ;;
    t) TIMEOUT="$OPTARG" ;;
    s) SLEEP="$OPTARG" ;;
    q) QUIET=1 ;;
    *) usage ;;
  esac
done

if [[ -z "$IFACE" ]]; then
  usage
fi

# helper prints
log() {
  if [[ $QUIET -eq 0 ]]; then
    echo "$@"
  fi
}

# check functions
check_carrier() {
  local f="/sys/class/net/${IFACE}/carrier"
  if [[ -r "$f" ]]; then
    local val
    val=$(cat "$f" 2>/dev/null) || return 1
    [[ "$val" = "1" ]]
    return
  fi
  return 2  # carrier not available
}

check_nmcli() {
  if command -v nmcli >/dev/null 2>&1; then
    # nmcli outputs e.g. "eth0:connected" with -t -f DEVICE,STATE device
    local state
    state=$(nmcli -t -f DEVICE,STATE device 2>/dev/null | awk -F: -v dev="$IFACE" '$1==dev{print $2; exit}')
    [[ "$state" = "connected" ]]
    return
  fi
  return 2
}

check_ip_link() {
  # fallback: ip link show dev IFACE and look for "state UP"
  if command -v ip >/dev/null 2>&1; then
    ip link show dev "$IFACE" 2>/dev/null | grep -q "state UP" && return 0 || return 1
  fi
  return 2
}

is_connected() {
  # try carrier first
  check_carrier
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    return 0
  elif [[ $rc -eq 1 ]]; then
    return 1
  fi
  # try nmcli
  check_nmcli
  rc=$?
  if [[ $rc -eq 0 ]]; then
    return 0
  elif [[ $rc -eq 1 ]]; then
    return 1
  fi
  # fallback ip link
  check_ip_link
  rc=$?
  if [[ $rc -eq 0 ]]; then
    return 0
  elif [[ $rc -eq 1 ]]; then
    return 1
  fi
  # unknown => treat as not connected
  return 1
}

start_ts=$(date +%s)
end_ts=0
if [[ $TIMEOUT -gt 0 ]]; then
  end_ts=$((start_ts + TIMEOUT))
fi

log "Waiting for interface '$IFACE' to become connected..."
while true; do
  if is_connected; then
    log "Interface '$IFACE' is connected."
    exit 0
  fi

  if [[ $TIMEOUT -gt 0 ]]; then
    now=$(date +%s)
    if [[ $now -ge $end_ts ]]; then
      log "Timeout after ${TIMEOUT}s waiting for '$IFACE'."
      exit 1
    fi
  fi

  sleep "$SLEEP"
done

#!/usr/bin/env bash

set -e

# Uncomment next line to debug the script
# set -x

log() {
  >&2 echo -e "\n:: $* \n"
}

installUpgrade() {
  local file="$1"

  log "Uploading the file"
  curl -v http://192.168.5.1/store/fw6_update.7z \
    -F "fw6_update.7z=@${file}"
  echo ""

  log "Performing the update"
  curl -v http://192.168.5.1/cmd \
    -H 'Content-Type: application/json' \
    -d '{"cmd": "updateFirmware", "from": "ram"}'
  echo ""
}

getSysinfo() {
  curl -s http://192.168.5.1/cmd \
    -H 'Content-Type: application/json' \
    -d '{"cmd": "getSysinfo"}' \
    "$@"
}

getFirmwareVersion() {
  getSysinfo | jq .firmwareVersion
}

waitUntilAvailable() {
  while sleep 5s; do
    log "Waiting for camera to become available"
    if getSysinfo --connect-timeout 10 >/dev/null; then
      return 0
    fi
  done
}

isLegacyAPI() {
  test "$(getSysinfo | jq .retCode)" -eq 3
}

legacyAPI_installUpgrade() {
  local file="$1"

  log "Uploading the file"
  curl -v http://192.168.5.1/store/fw6_update.7z \
    -F "fw6_update.7z=@${file}"
  echo ""

  log "Performing the update"
  curl -v http://192.168.5.1/cmd \
    -H 'Content-Type: application/json' \
    -d '{"cmd": 13, "fromRAM": 1}'
  echo ""
}

# shellcheck disable=SC2120 # Disable warning for never-passed "$@"
legacyAPI_getSysinfo() {
  curl -s http://192.168.5.1/cmd \
    -H 'Content-Type: application/json' \
    -d '{"cmd": 12}' \
    "$@"
}

legacyAPI_getFirmwareVersion() {
  legacyAPI_getSysinfo | jq .fwVersion
}

fwUpdateFile="$1"
if [[ -z "${fwUpdateFile}" ]]; then
  >&2 echo "Error: no FW update file passed"
  >&2 echo ""
  >&2 echo "Usage: ${0} <FW UPDATE FILE>"
  exit 11
fi

waitUntilAvailable

if isLegacyAPI; then
  log "Detected LEGACY FW: $(legacyAPI_getFirmwareVersion)"
  legacyAPI_installUpgrade "${fwUpdateFile}"
else
  log "Detected FW: $(getFirmwareVersion)"
  installUpgrade "${fwUpdateFile}"
fi

waitUntilAvailable

if isLegacyAPI; then
  log "Updated to LEGACY FW: $(legacyAPI_getFirmwareVersion)"
else
  log "Updated to FW: $(getFirmwareVersion)"
fi

# vim: sw=2 ft=sh :

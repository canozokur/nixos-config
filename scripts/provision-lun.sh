#!/usr/bin/env bash
# Provision a truenas-backed iSCSI LUN, formatted ext4 on the truenas side.
#
# Creates the zvol dataset, formats it ext4, then creates an iscsi extent and
# a target named after the volume, and attaches the extent at lunid 0.
#
# usage: provision-lun <name> <size>
#   name  dataset + iscsi target name, e.g. "logseq"
#   size  zfs-style size, e.g. 100G
#
# env: TRUENAS_SSH (default root@truenas), POOL (default: first pool).
# Portal and initiator group are copied from the first existing target
# Remote commands are intentionally assembled client-side.
# shellcheck disable=SC2029
set -euo pipefail

name="${1:?usage: provision-lun <name> <size>}"
size="${2:?usage: provision-lun <name> <size>}"
truenas="${TRUENAS_SSH:-root@truenas}"

need() { command -v "$1" >/dev/null || { echo "missing dependency: $1" >&2; exit 1; }; }
need jq
need ssh

die() { echo "error: $*" >&2; exit 1; }
# midclt payloads are json built with jq; they never contain single quotes,
# so wrapping in single quotes is safe on the remote shell.
tn() { ssh "$truenas" "midclt call $1 '$2'"; }

echo "== truenas: checking pools"
if [ -n "${POOL:-}" ]; then
  pool="$POOL"
else
  pool=$(ssh "$truenas" "midclt call pool.query '[]'" | jq -r '.[0].name')
  [ -n "$pool" ] && [ "$pool" != "null" ] || die "no pool found; set POOL=<pool>"
  echo "   using pool: $pool (set POOL to override)"
fi
ds="$pool/$name"

echo "== truenas: dataset $ds"
filter=$(jq -nc --arg n "$ds" '[["name","=",$n]]')
found=$(ssh "$truenas" "midclt call pool.dataset.query '$filter'" | jq -r '.[0].id // empty')
if [ -n "$found" ]; then
  echo "   already exists, skipping create"
else
  # middleware wants volsize as integer bytes
  payload=$(jq -nc --arg name "$ds" --argjson volsize "$(numfmt --from=iec "$size")" '{type: "VOLUME", name: $name, volsize: $volsize}')
  ssh "$truenas" "midclt call pool.dataset.create '$payload'" >/dev/null
fi

echo "== truenas: formatting /dev/zvol/$ds (ext4)"
if ssh "$truenas" "blkid -s UUID -o value /dev/zvol/$ds" 2>/dev/null | grep -q .; then
  echo "   already formatted, skipping mkfs"
else
  ssh "$truenas" "mkfs.ext4 /dev/zvol/$ds" >/dev/null
fi
uuid=$(ssh "$truenas" "blkid -s UUID -o value /dev/zvol/$ds")
[ -n "$uuid" ] || die "no uuid after formatting"

echo "== truenas: iscsi extent"
payload=$(jq -nc --arg name "lun-$name" --arg disk "zvol/$ds" '{type: "DISK", name: $name, disk: $disk}')
filter=$(jq -nc --arg n "lun-$name" '[["name","=",$n]]')
ext_id=$(ssh "$truenas" "midclt call iscsi.extent.query '$filter'" | jq -r '.[0].id // empty')
if [ -z "$ext_id" ]; then
  ext_id=$(ssh "$truenas" "midclt call iscsi.extent.create '$payload'" | jq -r '.id')
  echo "   created extent id $ext_id"
else
  echo "   extent already exists (id $ext_id)"
fi

echo "== truenas: target $name"
groups=$(ssh "$truenas" "midclt call iscsi.target.query '[]'" | jq -c '[.[] | select(.name | startswith("pvc-") | not)][0].groups')
[ -n "$groups" ] && [ "$groups" != "null" ] || die "no fleet target found to copy portal/initiator group from"
target_id=$(ssh "$truenas" "midclt call iscsi.target.query '$(jq -nc --arg n "$name" '[["name","=",$n]]')'" | jq -r '.[0].id // empty')
if [ -z "$target_id" ]; then
  payload=$(jq -nc --arg name "$name" --argjson groups "$groups" '{name: $name, groups: $groups}')
  target_id=$(ssh "$truenas" "midclt call iscsi.target.create '$payload'" | jq -r '.id')
  echo "   created target $name (id $target_id)"
else
  echo "   target $name already exists (id $target_id)"
fi

echo "== truenas: attaching extent to target $name"
te_filter=$(jq -nc --argjson t "$target_id" '[["target","=",$t]]')
lunid=$(ssh "$truenas" "midclt call iscsi.targetextent.query '$te_filter'" | jq -r 'map(.lunid) | (max // -1) + 1')
payload=$(jq -nc --argjson target "$target_id" --argjson extent "$ext_id" --argjson lunid "$lunid" '{target: $target, extent: $extent, lunid: $lunid}')
ssh "$truenas" "midclt call iscsi.targetextent.create '$payload'" >/dev/null
echo "   attached as lunid $lunid"

echo
echo "done. paste into the consuming service module:"
echo "  device = \"/dev/disk/by-uuid/$uuid\";"
echo "  fsType = \"ext4\";"

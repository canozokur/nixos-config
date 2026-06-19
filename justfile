alias rebuild := switch
alias r := switch
alias b := switch
alias dry := dry-build
alias push := push-build

switch:
  nixos-rebuild --sudo switch --flake .

# usage: push-build rpi01 canozokur@192.168.1.60
push-build host uri=host:
  nixos-rebuild --sudo switch --flake .#{{host}} --target-host {{uri}}

dry-build host="":
  nixos-rebuild dry-build --flake .#{{host}}

dry-activate:
  nixos-rebuild --sudo dry-activate --flake .

test:
  nixos-rebuild --sudo test --flake .

update-secrets:
  nix flake update nix-secrets

update-all:
  nix flake update

update-all-and-switch:
  nix flake update
  nixos-rebuild --sudo switch --profile-name update-`date "+%D@%T"` --flake .

_rebuild-boot:
  nixos-rebuild --sudo boot --flake .

purge-all: && _rebuild-boot
  rm -rf ~/.cache/direnv
  sudo nix-collect-garbage -d

purge-old: && _rebuild-boot
  sudo nix-collect-garbage --delete-older-than 7d

# usage: services rpi01
services box:
  #!/usr/bin/env bash
  set -euo pipefail
  nix eval --json '.#boxes."{{box}}"' \
    | jq -r '
      "{{box}} (\(.system), users: \(.users | join(", ")))",
      "  System services:",
      (if (.services // []) == [] then ["    (none)"] else (.services     | map("    - \(.)")) end | .[]),
      "  User services:",
      (if (.userServices // []) == [] then ["    (none)"] else (.userServices | map("    - \(.)")) end | .[]),
      ""
    '

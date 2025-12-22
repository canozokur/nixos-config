alias rebuild := switch
alias r := switch
alias b := switch
switch:
  nixos-rebuild --sudo switch --flake .

# usage: push-build rpi01 canozokur@192.168.1.60
push-build host uri=host:
  nixos-rebuild --sudo switch --flake .#{{host}} --target-host {{uri}}

dry-build:
  nixos-rebuild dry-build --flake .

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

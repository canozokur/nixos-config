alias rebuild := switch
alias r := switch
alias b := switch
switch:
  nixos-rebuild --sudo switch --flake .

dry-build:
  nixos-rebuild dry-build --flake .

dry-activate:
  nixos-rebuild --sudo dry-activate --flake .

test:
  nixos-rebuild --sudo test --flake .

update-secrets:
  nix flake update nix-secrets

_rebuild-boot:
  nixos-rebuild --sudo boot --flake .

purge-all: && _rebuild-boot
  rm -rf ~/.cache/direnv
  sudo nix-collect-garbage -d

purge-old: && _rebuild-boot
  sudo nix-collect-garbage --delete-older-than 7d

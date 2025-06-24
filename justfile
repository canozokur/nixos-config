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

update secrets:
  nix flake update nix-secrets

# target: all, old
purge target:
  {{ if target == "all" { "rm -rf ~/.cache/direnv" } else { "" } }}
  sudo {{ if target == "all" { "nix-collect-garbage -d" } else { "nix-collect-garbage --delete-older-than 7d" } }}
  nixos-rebuild --sudo boot --flake .

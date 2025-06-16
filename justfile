alias rebuild := switch
alias r := switch
alias b := switch
switch:
  nixos-rebuild --use-remote-sudo switch --flake .

dry-build:
  nixos-rebuild dry-build --flake .

dry-activate:
  nixos-rebuild dry-activate --flake .

test:
  nixos-rebuild --use-remote-sudo test --flake .

update secrets:
  nix flake update nix-secrets

switch:
  nixos-rebuild --use-remote-sudo switch --flake .

update secrets:
  nix flake update nix-secrets

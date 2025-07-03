{ inputs, ... }:
{
  nixpkgs.overlays = [
    (import ./zjstatus.nix { inherit inputs; })
  ];
}

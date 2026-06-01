| `main ws` | `single window` |
|---------------|----------------|
| ![wrap](https://github.com/user-attachments/assets/1dc616c5-73b7-4ff5-829e-40c6d89ca5bd) | ![nowrap](https://github.com/user-attachments/assets/df65dd13-558e-4446-a91b-671405924824) |

# ❄️Personal NixOS Configuration

This repository contains the declarative configuration for my personal infrastructure, ranging from my workstations to Raspberry Pi servers at home. It is built on Nix Flakes and I kinda use a twisted dependency injection system.

## Folder Structure

```graphql
├── boxes/            # Per-machine definitions (hardware + identity facts)
│   ├── nexusbox/     # Workstation (Dell XPS)
│   ├── homebox/      # Gaming / virt host
│   ├── rpi01..04/    # Raspberry Pi cluster nodes
│   └── tr.pco.pink/  # VPS
├── profiles/         # Reusable system roles
│   ├── core/         # Common to every host
│   ├── capabilities/ # Atomic single-purpose modules
│   └── *.nix         # Composite roles (server, monitoring, …)
├── users/
│   └── canozokur/
│       ├── default.nix
│       ├── profiles/ # Home-Manager role profiles
│       └── programs/ # Per-program HM configs (nixvim, hyprland, …)
├── modules/
│   └── host-options.nix  # The _meta option schema
├── lib/
│   ├── mkbox.nix     # System builder (wraps `lib.nixosSystem`)
│   ├── helpers.nix   # Fleet-aware helpers (getHostsWith, getProxy, …)
│   └── constants.nix # Fleet-wide constants (SSL domains, NFS endpoints)
├── flake.nix         # Entry point
└── justfile          # Common task shortcuts
```

## Development tools

`nix develop` drops you into a shell with `sops`, `age`, `ssh-to-age`, `just`, `dnsutils`, and `nixfmt` available.

## Flake exposed packages

### Neovim (via nixvim)
```bash
nix run github:canozokur/nixos-config#neovim
```

### SD images
Hosts that import the SD-image module (the Pi cluster) expose an `images` output:
```bash
nix build .#images.rpi01
```

## The `_meta` attribute

Each host declares its identity via a custom `_meta` option, and other modules adapt by reading peers' `_meta` from `inputs.self.nixosConfigurations`.

### 1. Declaring state

In `boxes/<host>/default.nix`:
```nix
{ ... }: {
  _meta = {
    networks = {
      externalIP = "192.168.1.5";
      internalIP = "192.168.1.5";
    };
    services.consulServer = true;
    dnsConfigurations = [
      { ip = "192.168.1.129"; domain = "truenas.lan"; }
    ];
  };
}
```

The full schema lives in `modules/host-options.nix`.

### 2. Consuming state

Aggregator profiles read peers' `_meta` via `helpers.getHostsWith`. Example: auto-generating `/etc/hosts` entries for every host that declares a DNS record:
```nix
{ inputs, helpers, lib, ... }: let
  hosts = helpers.getHostsWith inputs.self.nixosConfigurations [ "dnsConfigurations" ];
  entries = lib.flatten (lib.mapAttrsToList (_: h:
    map (e: "${e.ip} ${e.domain}") h.config._meta.dnsConfigurations
  ) hosts);
in {
  networking.extraHosts = lib.concatStringsSep "\n" entries;
}
```

## mkBox (`lib/mkbox.nix`)

`mkBox` is the per-host system builder. Each box is declared in `flake.nix` with two independent profile lists — `profiles` for the system side and `userProfiles` for Home-Manager. A typo on either side fails the build, and a system role with no user-side counterpart (e.g. `sunshine`, `virt-host`) just lists nothing under `userProfiles`.

```nix
boxes = {
  homebox = {
    system = "x86_64-linux";
    users = [ "canozokur" ];
    profiles     = [ "gaming" "sunshine" "virt-host" ];
    userProfiles = [ "gaming" ];
  };
};
```

`mkBox` also threads `inputs`, `helpers`, and `constants` through as `specialArgs` (and `extraSpecialArgs` for Home-Manager), so any module can pull them straight from its function args.

## Helpers (`lib/helpers.nix`)

* **`getHostsWith hosts path`** — Returns the subset of `hosts` whose `config._meta.<path>` is non-default (i.e. not null/""/[]/false/{}). Used to find peers that meaningfully contribute to a fleet-level aggregate.
    ```nix
    helpers.getHostsWith inputs.self.nixosConfigurations [ "networks" "externalIP" ];
    ```
* **`getProxy hosts`** — Finds the unique host with `_meta.services.reverseProxy.enable = true`. Throws if 0 or >1 hosts match. Returns `{ externalIP; internalIP; hostname; }`.
* **`listToNumberedAttrs prefix list`** — Converts `[ "a" "b" ]` to `{ prefix1 = "a"; prefix2 = "b"; }`. Used to build NetworkManager `address1`/`address2`/… keys.

## Constants (`lib/constants.nix`)

Fleet-wide invariants — SSL domains, the TrueNAS endpoint, etc. — live in `lib/constants.nix` and are passed through via `specialArgs`. Any module can read them from its args:
```nix
{ constants, ... }: {
  fileSystems."/shared".device =
    "${constants.fleet.storage.truenas}:${constants.fleet.storage.sharedVolume}";
}
```

## Usage

### Bootstrap a new machine
1. Boot the NixOS installer ISO.
2. Clone:
    ```bash
    git clone https://github.com/canozokur/nixos-config /etc/nixos
    ```
3. Generate hardware config:
    ```bash
    nixos-generate-config --show-hardware-config > ./boxes/newbox/hardware-configuration.nix
    ```
4. Add the new box entry to `flake.nix` and fill in `boxes/newbox/`.
5. Install:
    ```bash
    nixos-install --flake .#newbox
    ```

### Day-to-day

`justfile` defines the common tasks:
```bash
just switch                              # Rebuild and activate the current host
just dry                                 # Dry build (no activation)
just push rpi01 canozokur@192.168.1.60   # Build locally, push to a remote
just update-all                          # Update every flake input
just update-secrets                      # Update only nix-secrets
```

## Secrets

Managed via [sops-nix](https://github.com/Mic92/sops-nix) with secrets stored in a separate private flake input (`inputs.nix-secrets`).

## License

MIT

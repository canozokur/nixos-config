# ❄️Personal NixOS Configuration

This repository contains the declarative configuration for my personal infrastructure, ranging from my workstations to Raspberry Pi servers at home. It is built on Nix Flakes and I kinda use a twisted dependency injection system.

## Folder Structure

```graphql
├── boxes/          # Machine definitions (Hardware + Role)
│   ├── nexusbox/   # Workstation (Dell XPS)
│   ├── rpi01/      # Cluster Node 1
│   └── ...
├── users/          # User definitions & Home Manager profiles
│   ├── canozokur/  # Main user environment
│   └── ...
├── profiles/       # Reusable system layers
├── modules/        # Custom NixOS modules
│   ├── meta.nix    # The schema for exported metadata from boxes
│   └── ...
├── lib/            # Custom helpers
│   ├── mkbox.nix   # The system builder wrapper
│   └── helpers.nix # Node filtering logic
├── secrets/        # Encrypted secrets (sops)
└── flake.nix       # Entry point
```

## Development tools

There's a `devShells` definition in the flake so you can do `nix develop` and you should get a shell with sops, age, ssh-to-age and just tools available.

## The "_meta" attributes

Nodes declare their properties via a custom `_meta` option, and the modules will adapt using those.

### 1. Declaring State (The Contract)
Every machine defines its identity in its configuration (`boxes/<host>/default.nix`):

```nix
{ ... }: {
  # Define static facts about this node
  _meta = {
    networks = {
      externalIP = "192.168.1.50";
      internalIP = "1.1.1.1";
    };
    dnsConfigurations = [
      { ip = "192.168.1.50"; domain = "cluster.lan"; }
    ];
  };
}
```

### 2. Consuming State (Service Discovery)
Using custom helpers, other modules can aggregate this data to configure services.

Example: **Auto-generating DNS records for the nodes:**

```nix
{ inputs, helpers, ... }:
let
  # Filter the fleet for hosts that actually have DNS config
  hosts = helpers.getHostsWith inputs.self.nixosConfigurations "dnsConfigurations";
  
  # Generate /etc/hosts entries
  entries = lib.flatten (lib.mapAttrsToList (_: h: 
    map (e: "${e.ip} ${h.config.networking.hostName}.${e.domain}") h.config._meta.dnsConfigurations
  ) hosts);
in {
  networking.extraHosts = lib.concatStringsSep "\n" entries;
}
```

## mkBox (`lib/mkbox.nix`)

This one binds everything together. It's a function that includes modules for users and boxes. Each profile defined in the `flake.nix` file will be included here for each box and user (which means they will become home-manager modules).

```nix
# machines (boxes) are defined in flake.nix and for this example,
# this machine will include profiles/virtual.nix profiles/desktop.nix etc.
# also the user profiles under users/canozokur/profiles/virtual.nix etc. will be included
    boxes = {
      virtnixbox = {
        system = "x86_64-linux";
        users = [ "canozokur" ];
        profiles = [ "virtual" "desktop" "coding" "gaming" ];
      };
```

## Helpers (`lib/helpers.nix`)

This one is a custom library to filter out the flake inputs, based on a given path's existince.

*   **`getHostsWith hosts path`**:
    Returns an attribute set of machines where the specified configuration option (`path`) is defined and valid (not null, not empty).

    ```nix
    # Get all nodes that exposes an external IP address
    nodesWithExternalIP = helpers.getHostsWith inputs.self.nixosConfigurations ["networks" "externalIP"];
    ```

## Usage

### Bootstrap a new machine
1.  Boot into the NixOS Installation ISO.
2.  Clone this repo:
    ```bash
    git clone https://github.com/canozokur/nixos-config /etc/nixos
    ```
3.  Generate hardware config (if new hardware):
    ```bash
    nixos-generate-config --show-hardware-config > ./boxes/newbox/hardware-configuration.nix
    ```
4.  Add the new box to `flake.nix` and `boxes/`.
5.  Install:
    ```bash
    nixos-install --flake .#newbox
    ```

### Updates
`just` to manage common tasks:

```bash
just switch         # Rebuild and switch current system
just dry            # Dry build to check for errors
just build-image rpi01  # Build SD card image for rpi01
```

## Secrets

Secrets are managed via **sops-nix**.

## License

MIT

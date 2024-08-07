{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-edge.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvidia-patch = {
      url = "github:keylase/nvidia-patch";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-edge, home-manager, nvidia-patch, ... }@attrs: {
    nixosConfigurations."Nix-Rafal" = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      specialArgs = { inherit attrs; };

      modules = [
        ./hosts/Nix-Rafal
        home-manager.nixosModules.home-manager
        {
          # Add unstable overlay as pkgs.edge
          nixpkgs.overlays = [
            (final: prev: {
              edge = import nixpkgs-edge {
                inherit system;
                config.allowUnfree = true;
              };
            })
          ];

          nix.registry.nixpkgs.flake = nixpkgs;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
  };
}

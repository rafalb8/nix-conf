{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-edge.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvidia-patch = {
      url = "github:keylase/nvidia-patch";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-edge, home-manager, nvidia-patch, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-edge = import nixpkgs-edge {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Custom Packages
      packages.${system} = {
        fastflix = pkgs.callPackage ./packages/fastflix.nix { };
        nvencc = pkgs-edge.callPackage ./packages/nvencc.nix { };
        sgdboop = pkgs-edge.callPackage ./packages/sgdboop.nix { };
        sunshine = pkgs-edge.callPackage ./packages/sunshine.nix { };
      };

      # Overlays
      overlays = {
        # NixOS unsable overlay
        edge = final: prev: {
          edge = import nixpkgs-edge {
            inherit (final) system;
            config.allowUnfree = true;
          };
        };

        # Custom packages overlay
        custom = final: prev: {
          custom = self.packages.${final.system};
        };
      };

      # NixOS configurations
      nixosConfigurations = {
        # Main PC
        "Nix-Rafal" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/Nix-Rafal
            ./extensions/home-manager
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.edge self.overlays.custom ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
        "T14-gen3" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/T14-gen3
            ./extensions/home-manager
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.edge self.overlays.custom ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        };
      };
    };
}

{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-edge.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixpkgs-old.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvidia-patch = {
      url = "github:keylase/nvidia-patch";
      flake = false;
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-edge
    , nixpkgs-old
    , home-manager
    , nvidia-patch
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs-old = nixpkgs-old.legacyPackages.${system};
      pkgs = import nixpkgs-edge {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Custom Packages
      packages.${system} = {
        fastflix = pkgs-old.callPackage ./packages/fastflix.nix { };
        nvencc = pkgs.callPackage ./packages/nvencc.nix { };
        sgdboop = pkgs.callPackage ./packages/sgdboop.nix { };
        sunshine = pkgs.callPackage ./packages/sunshine.nix { };
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
      nixosConfigurations = nixpkgs.lib.genAttrs
        [ "Nix-Rafal" "T14-gen3" ]
        (hostname: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/${hostname}
            ./extensions/home-manager
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.edge self.overlays.custom ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        });
    };
}

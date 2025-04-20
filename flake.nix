{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
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
    , nixpkgs-stable
    , chaotic
    , home-manager
    , nvidia-patch
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Custom Packages
      packages.${system} = {
        fastflix = pkgs.callPackage ./packages/fastflix.nix { };
        vceencc = pkgs.callPackage ./packages/vceencc.nix { };

        sgdboop = pkgs.callPackage ./packages/sgdboop.nix { };
        nvidia = pkgs.callPackage ./packages/nvidia-patch.nix { inherit nvidia-patch; };
      };

      # Overlays
      overlays = {
        # Custom packages overlay
        custom = final: prev: {
          custom = self.packages.${final.system};
        };

        # Stable channel overlay
        stable = final: prev: {
          stable = import nixpkgs-stable {
            inherit (final) system;
            config.allowUnfree = true;
          };
        };
      };

      # NixOS configurations
      nixosConfigurations = nixpkgs.lib.genAttrs
        [ "Mainframe" "T14-gen3" ]
        (hostname: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./modules
            ./extensions
            ./hosts/${hostname}

            # Chaotic
            chaotic.nixosModules.default

            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.custom self.overlays.stable ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        });
    };
}

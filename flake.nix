{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nix-colors.url = "github:misterio77/nix-colors";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , nixpkgs-stable
    , chaotic
    , nix-colors
    , lanzaboote
    , nur
    , home-manager
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
      };

      # Overlays
      overlays = {
        custom = final: prev: {
          # Custom packages overlay
          custom = self.packages.${final.system};
          # Fixes
          qgnomeplatform-qt6 = nixpkgs-stable.legacyPackages.${final.system}.qgnomeplatform-qt6;
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
        [ "Mainframe" "T14-gen3" "Nexus" ]
        (hostname: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./modules
            ./extensions
            ./hosts/${hostname}

            chaotic.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.custom self.overlays.stable nur.overlays.default ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        });
    };
}

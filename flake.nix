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
      pkgs = import nixpkgs
        {
          inherit system;
          config.allowUnfree = true;
        } // {
        stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };

      lib = pkgs.lib // {
        custom = import ./custom/lib { inherit (pkgs) lib; };
      };
    in
    {
      # Custom Packages
      packages.${system} = {
        fastflix = pkgs.callPackage ./custom/packages/fastflix.nix { };
      };

      # Overlays
      overlays.default = final: prev: {
        # Custom library overlay
        inherit lib;

        # Custom packages overlay
        custom = self.packages.${final.system};

        # Stable channel overlay
        stable = pkgs.stable;

        # Replace broken packages
        qgnomeplatform-qt6 = pkgs.stable.qgnomeplatform-qt6;
      };

      # NixOS configurations
      nixosConfigurations = nixpkgs.lib.genAttrs
        [ "Mainframe" "T14-gen3" "Nexus" ]
        (hostname: nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs lib; };

          modules = [
            ./modules
            ./extensions
            ./hosts/${hostname}

            chaotic.nixosModules.default
            lanzaboote.nixosModules.lanzaboote
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [ self.overlays.default nur.overlays.default ];

              nix.registry.nixpkgs.flake = nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
          ];
        });
    };
}

{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

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
        custom = import ./lib { inherit pkgs; };
      };
    in
    {
      # Custom Packages
      packages.${system} = with nixpkgs.lib; mapAttrs'
        (fname: _: {
          name = removeSuffix ".nix" fname;
          value = pkgs.callPackage ./packages/${fname} { };
        })
        (builtins.readDir ./packages);

      # Overlays
      overlays.default = final: prev: {
        # Custom library overlay
        inherit lib;

        # Custom packages overlay
        custom = self.packages.${final.system};

        # Stable channel overlay
        stable = pkgs.stable;

        # Replace broken packages
      } // lib.genAttrs [ ] (name: pkgs.stable.${name});

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

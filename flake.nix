{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvidia-patch = {
      url = "github:keylase/nvidia-patch";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, nvidia-patch, ... }@attrs: {
    nixosConfigurations."Nix-Rafal" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit attrs;

        # pkgs-stable = import nixpkgs-stable {
        #   inherit system;
        #   config.allowUnfree = true;
        # };
      };

      modules = [
        ({ ... }: { nix.registry.nixpkgs.flake = nixpkgs; })
        ./hosts/Nix-Rafal

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };
  };
}

{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations."Nix-Rafal" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = inputs;

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

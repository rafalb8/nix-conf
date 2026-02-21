{ config, lib, ... }:
{
  # NixOS extensions
  imports = [
    ./autostart.nix
    ./firewall.nix

    # Programs
    ./programs/fastflix.nix
  ];

  # User options
  options.user = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "System username";
    };

    description = lib.mkOption {
      type = lib.types.str;
      description = "System user description ie. First and last name";
    };
  };

  config = {
    # Home-Manager extensions
    home-manager.users.${config.user.name} = {
      imports = [
        ./home-manager/easyeffects
      ];
    };
  };
}

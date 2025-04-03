{ config, lib, ... }:
{
  # NixOS extensions
  imports = [
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
    home-manager.users.${config.user.name}.imports = [
      ./home-manager/easyeffects
      ./home-manager/autostart.nix
    ];
  };
}

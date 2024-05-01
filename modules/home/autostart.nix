# Home-Manager autostart module for managing desktop applications
# Import inside home-manager.users.${config.user.name}
{ config, lib, ... }:
let
  cfg = config.autostart;
in
{
  options.autostart = {
    enable = lib.mkEnableOption "Enable autostart module";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "List of packages to be autostarted";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.xdg.enable;
        message = "xdg.enable must be true, required for xdg.configFile";
      }
    ];

    xdg.configFile = builtins.listToAttrs (map
      (pkg:
        let
          name = if pkg ? pname then pkg.pname else pkg.name;
          # TODO: Find a better way of supporting custom entries.
          # Currently, if a custom entry is generated, it requires a subsequent execution of nixos-rebuild to take effect.
          customPath = config.home.homeDirectory + "/.nix-profile/share/applications/" + name + ".desktop";
        in
        {
          name = "autostart/" + name + ".desktop";
          value =
            if builtins.pathExists customPath then {
              # Use custom desktop entry
              source = customPath;
            } else if pkg ? desktopItem then {
              # If pkg contains text attribute
              text = pkg.desktopItem.text;
            } else if pkg ? source then {
              # Custom source name
              source = pkg + "/share/applications/" + pkg.source;
            } else {
              # Others
              source = pkg + "/share/applications/" + name + ".desktop";
            };
        }
      )
      cfg.packages);
  };
}

# Autostart module for desktop applications
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
      description = ''
        List of packages to be autostarted.
        To override Exec command:
        (pkgs.pkg // {
          exec = "''${pkgs.pkg}/bin/pkg";
        })
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services = builtins.listToAttrs (map
      (pkg:
        {
          name = "autostart-" + pkg.pname;
          value = {
            enable = true;
            description = "Autostart service for ${pkg.pname}";

            wantedBy = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            wants = [ "graphical-session.target" ];
            after = [ "graphical-session.target" ];

            unitConfig = { ConditionEnvironment = [ "!XDG_CURRENT_DESKTOP=Hyprland" ]; };

            startLimitIntervalSec = 500;
            startLimitBurst = 5;

            serviceConfig = {
              ExecStart = pkg.exec or "/run/current-system/sw/bin/${pkg.pname}";
              Restart = "on-failure";
              RestartSec = "5s";
            };
            path = [ "/run/current-system/sw" ];
          };
        }
      )
      cfg.packages);
  };
}

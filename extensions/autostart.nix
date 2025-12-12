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
        To override Exec Command or Environment variables:
        (pkgs.pkg // {
          exec = "''${pkgs.pkg}/bin/pkg";
          env = { ENV = "true";};
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
            after = [ "graphical-session.target" ];
            serviceConfig = {
              Type = "simple";
              ExecStart = pkg.exec or "${pkg}/bin/${pkg.pname}";
              Restart = "on-failure";
              RestartSec = "5s";
            };
            environment = pkg.env or { };
          };
        }
      )
      cfg.packages);
  };
}

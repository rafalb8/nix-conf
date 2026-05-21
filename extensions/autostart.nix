# Autostart module for desktop applications
{ config, lib, pkgs, ... }:
let
  cfg = config.autostart;

  mkAutostartItem = { name, exec, env ? { } }:
    pkgs.makeDesktopItem {
      inherit name;
      desktopName = name;
      exec = "${lib.custom.toEnvPrefix env}${exec}";
      type = "Application";
      noDisplay = true;
    };
in
{
  options.autostart = {
    enable = lib.mkEnableOption "Enable autostart module";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = ''
        List of packages to be autostarted.
        Supports overrides for 'exec' and 'env' e.g.:
        (pkgs.pkg // {
          env = { ENV = "true";};
          exec = "''${pkgs.pkg}/bin/pkg";
        })
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc = builtins.listToAttrs (map
      (pkg:
        let
          name = pkg.pname or pkg.name;
          autostartItem = mkAutostartItem {
            inherit name;
            env = pkg.env or { };
            exec = pkg.exec or "${pkg}/bin/${name}";
          };
        in
        {
          name = "xdg/autostart/${name}.desktop";
          value = {
            source = "${autostartItem}/share/applications/${name}.desktop";
          };
        }
      )
      cfg.packages);
  };
}

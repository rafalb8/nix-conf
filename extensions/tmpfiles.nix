{ config, lib, ... }:
let
  linkOpts = lib.types.submodule {
    options = {
      target = lib.mkOption {
        type = lib.types.path;
        description = "Path where the symlink should be created.";
      };
      source = lib.mkOption {
        type = lib.types.either lib.types.path lib.types.package;
        description = "Target binary, library, package, or directory being pointed to.";
      };
      force = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "If true, uses 'L+' to overwrite existing files/links.";
      };
    };
  };

  dirOpts = lib.types.submodule {
    options = {
      path = lib.mkOption { type = lib.types.path; };
      mode = lib.mkOption { type = lib.types.str; default = "0755"; };
      user = lib.mkOption { type = lib.types.str; default = "root"; };
      group = lib.mkOption { type = lib.types.str; default = "root"; };
      ttl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "7d";
        description = "Time-to-live string (e.g. 10d, 12h) to automatically prune stale files.";
      };
    };
  };

in
{
  options.systemd.tmpfiles = {
    links = lib.mkOption {
      type = lib.types.listOf linkOpts;
      default = [ ];
      example = lib.literalExpression ''
        [
          { target = "/lib64/ld-linux-x86-64.so.2"; source = "''${pkgs.glibc}/lib/ld-linux-x86-64.so.2"; }
          { target = "/usr/bin/env"; source = "''${pkgs.coreutils}/bin/env"; }
        ]
      '';
      description = "Structured symlink definitions transformed into systemd.tmpfiles.rules.";
    };

    directories = lib.mkOption {
      type = lib.types.listOf dirOpts;
      default = [ ];
      example = lib.literalExpression ''
        [
          { path = "/var/cache/app-downloads"; ttl = "7d"; user = "appuser"; }
        ]
      '';
      description = "Structured directory definitions transformed into systemd.tmpfiles.rules.";
    };

    writes = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = lib.literalExpression ''
        {
          "/sys/class/backlight/intel_backlight/brightness" = "500";
        }
      '';
      description = "Values to write to files or sysfs nodes on boot via systemd.tmpfiles.rules.";
    };
  };

  config = {
    systemd.tmpfiles.rules =
      # 1. Links (L / L+)
      (map
        (l:
          let type = if l.force then "L+" else "L";
          in "${type} ${l.target} - - - - ${toString l.source}"
        )
        config.systemd.tmpfiles.links)

      # 2. Directories (d)
      ++ (map
        (d:
          let age = if d.ttl != null then d.ttl else "-";
          in "d ${d.path} ${d.mode} ${d.user} ${d.group} ${age}"
        )
        config.systemd.tmpfiles.directories)

      # 3. Writes (w)
      ++ (lib.mapAttrsToList
        (path: value:
          "w ${path} - - - - ${value}"
        )
        config.systemd.tmpfiles.writes);
  };
}

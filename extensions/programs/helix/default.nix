{ config, pkgs, lib, ... }:
let
  cfg = config.programs.helix;
  tomlFormat = pkgs.formats.toml { };
in
{
  options.programs.helix = {
    enable = lib.mkEnableOption "Helix editor";

    package = lib.mkPackageOption pkgs "helix" { };

    addons = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      example = lib.literalExpression ''with pkgs; [ gopls delve ]'';
      description = "List of additional packages to install such as lsp and dap";
    };

    config = lib.mkOption {
      type = tomlFormat.type;
      default = { };
      example = lib.literalExpression ''
        {
          theme = "edge";

          editor = {
            line-number = "relative";
            mouse = true;

            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };

            file-picker = {
              hidden = false;
            };
          };
        }
      '';
      description = ''
        Configuration written to
        {file}`$XDG_CONFIG_HOME/helix/config.toml`
        See <https://docs.helix-editor.com/configuration.html> for more info.
      '';
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ] ++ cfg.addons;

    home-manager.users.${config.user.name}.xdg.configFile = {
      # Install all themes
      "helix/themes" = {
        source = ./themes;
        recursive = true;
      };

      "helix/config.toml".source = (tomlFormat.generate "config.toml" cfg.config).overrideAttrs
        (finalAttrs: prevAttrs: {
          buildCommand = lib.concatStringsSep "\n" [
            prevAttrs.buildCommand
            "substituteInPlace $out --replace '\\\\' '\\'"
          ];
        });
    };


  };
}

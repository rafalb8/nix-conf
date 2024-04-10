{ config, lib, ... }:
let
  cfg = config.editors.helix;
in
{
  options.editors.helix = {
    enable = lib.mkEnableOption "Helix text editor";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.xdg.enable;
        message = "xdg.enable must be true, required for xdg.configFile";
      }
    ];

    # Install themes
    xdg.configFile."helix/themes" = {
      source = ./themes;
      recursive = true;
    };

    # Setup helix
    programs.helix = {
      enable = true;
      defaultEditor = true;

      languages.language = [
        {
          name = "go";
          auto-format = true;
        }
        {
          name = "nix";
          auto-format = true;
          formatter = { command = "nixpkgs-fmt"; };
        }
      ];

      settings = {
        theme = "edge";

        keys.normal = {
          space.space = ":format";
          # esc = [ "collapse_selection" "keep_primary_selection" ];
        };

        editor = {
          mouse = true;
          line-number = "relative";
          lsp.display-messages = true;

          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };

          file-picker = {
            hidden = false;
          };
        };
      };
    };
  };
}

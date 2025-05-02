{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # Firefox browsers
    programs.firefox = {
      enable = true;
      policies = {
        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            private_browsing = true;
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            private_browsing = true;
          };
        };
      };
    };

    # Chromium browsers
    environment.systemPackages = with pkgs; [ brave ];

    # Policies for chromium browsers
    programs.chromium = {
      enable = true;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
        "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
      ];
      extraOpts = {
        "PasswordManagerEnabled" = false;
        "SpellcheckEnabled" = true;
        "SpellcheckLanguage" = [
          "pl"
          "en-US"
        ];
      };
    };
  };
}

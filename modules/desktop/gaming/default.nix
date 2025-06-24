{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ./mangohud.nix ./experiments.nix ];

  config = lib.mkIf cfg.gaming.enable {
    boot.kernelParams = [ "split_lock_detect=off" ];

    warnings = lib.mkIf (pkgs.vintagestory.version > "1.20.11")
      [ "Vintage Story override not required" ];

    environment.systemPackages = with pkgs; [
      # Tools
      custom.sgdboop
      # protonup-qt

      # Wine guis
      bottles
      heroic
      # lutris

      # Emulators
      rpcs3

      # Games
      prismlauncher # Minecraft launcher
      (vintagestory.overrideAttrs (final: prev: {
        version = "1.20.12";
        src = builtins.fetchurl {
          url = "https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_${final.version}.tar.gz";
          sha256 = "sha256:1hd9xw3wf2h7fjbpjd0mi0kfzm6wb6pv8859p145ym8mk88ig9l7";
        };
      }))
    ];
    # Vintage Story dep
    nixpkgs.config.permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ];

    programs = {
      steam = {
        enable = true;
        remotePlay.openFirewall = true;
        protontricks.enable = true;
        extraCompatPackages = with pkgs; [
          steamtinkerlaunch
          proton-ge-bin
        ];
      };

      gamemode.enable = true;
      gamemode.enableRenice = true;
    };

    home-manager.users.${config.user.name} = {
      xdg = {
        enable = true;

        # Steam custom desktop entry
        desktopEntries.steam = {
          name = "Steam";
          icon = "steam";
          exec = "env MANGOHUD=1 steam -silent %U";
          terminal = false;
          categories = [ "Network" "FileTransfer" "Game" ];
          mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
          actions = {
            "Store" = { exec = "steam steam://store"; };
            "Library" = { exec = "steam steam://open/games"; };
            "Friends" = { exec = "steam steam://open/friends"; };
            "Settings" = { exec = "steam steam://open/settings"; };
            "BigPicture" = {
              name = "Big Picture";
              exec = "steam steam://open/bigpicture";
            };
          };
        };

        # Enable steamtinkerlaunch to use nix's proton packages
        configFile."steamtinkerlaunch/protonlist.txt".text = lib.concatMapStringsSep ""
          (pkg:
            let
              protonPath = "${pkg.steamcompattool.outPath}/proton";
            in
            lib.optionalString (builtins.pathExists protonPath) "${protonPath}\n"
          )
          config.programs.steam.extraCompatPackages;
      };

      # Autostart
      autostart = {
        enable = true;
        packages = [ pkgs.steam ];
      };
    };

  };
}

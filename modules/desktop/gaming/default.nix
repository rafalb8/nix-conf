{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;
in
{
  imports = [ ./streaming.nix ./mangohud.nix ./experiments.nix ];

  config = lib.mkIf cfg.gaming.enable {
    warnings = lib.mkIf (pkgs.vintagestory.version > "1.20.12")
      [ "Vintage Story permittedInsecurePackages might be not required" ];

    # Vintage Story dep
    nixpkgs.config.permittedInsecurePackages = [ "dotnet-runtime-7.0.20" ];

    environment.systemPackages = with pkgs; [
      # Tools
      sgdboop
      gamescope_git
      # protonup-qt

      # Wine guis
      heroic
      # lutris
      # bottles

      # Emulators
      rpcs3

      # Games
      prismlauncher # Minecraft launcher
      vintagestory
    ];

    hardware.steam-hardware.enable = true;
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

      gamemode.enable = false;
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
      };

      # Autostart
      autostart = {
        enable = true;
        packages = [ pkgs.steam ];
      };
    };

    # SteamOS Linux optimizations
    # https://github.com/fufexan/nix-gaming/blob/master/modules/platformOptimizations.nix
    boot.kernel.sysctl = {
      # 20-net-timeout.conf
      # This is required due to some games being unable to reuse their TCP ports
      # if they're killed and restarted quickly - the default timeout is too large.
      "net.ipv4.tcp_fin_timeout" = 5;
      # 30-splitlock.conf
      # Prevents intentional slowdowns in case games experience split locks
      # This is valid for kernels v6.0+
      "kernel.split_lock_mitigate" = 0;
      # 30-vm.conf
      # USE MAX_INT - MAPCOUNT_ELF_CORE_MARGIN.
      # see comment in include/linux/mm.h in the kernel tree.
      "vm.max_map_count" = 2147483642;
    };

  };
}

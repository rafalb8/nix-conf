{ config, ... }:
{
  wayland.windowManager.hyprland.settings = {
    env = [
      "GDK_SCALE,1"

      # Cursor size
      "XCURSOR_SIZE,24"
      "HYPRCURSOR_SIZE,24"

      # Cursor theme
      "XCURSOR_THEME,Adwaita"
      "HYPRCURSOR_THEME,Adwaita"

      # Force all apps to use Wayland
      "NIXOS_OZONE_WL,1"
      "GDK_BACKEND,wayland"
      "MOZ_ENABLE_WAYLAND,1"
      "OZONE_PLATFORM,wayland"
      "QT_QPA_PLATFORM,wayland"
      "SDL_VIDEODRIVER,wayland"
      "QT_STYLE_OVERRIDE,kvantum"
      "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      "CHROMIUM_FLAGS,\"--enable-features=UseOzonePlatform --ozone-platform=wayland --gtk-version=4\""

      # Make .desktop files available for wofi
      "XDG_DATA_DIRS,$XDG_DATA_DIRS:$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share"

      # GTK Theme
      "GTK_THEME,Adwaita:dark"

      "HYPRSHOT_DIR,${config.home.homeDirectory}/Pictures/Screenshots"
    ];

    xwayland = {
      force_zero_scaling = true;
    };

    ecosystem = {
      no_update_news = true;
    };
  };
}

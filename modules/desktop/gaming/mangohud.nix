{ config, pkgs, lib, ... }:
let
  cfg = config.modules.desktop;

  configLine = key: value:
    if value == true then "${key}"
    else if value == false then "${key}=0"
    else "${key}=${builtins.toString value}";

  toConfig = with builtins; data: concatStringsSep "\n" (map
    (k:
      let v = getAttr k data; in
      if isAttrs v then "${k}\n${toConfig v}\n"
      else configLine k v
    )
    (attrNames data)
  );

  MangoHud = {
    # Keybinds
    toggle_preset = "Shift_R+F12";
    toggle_fps_limit = "Shift_R+F11";

    # Disable Keybinds (Setting to "" causes bug with flickering hud and logging)
    toggle_hud = "Shift_R+F13";
    toggle_hud_position = "Shift_R+F13";
    toggle_logging = "Shift_R+F13";

    # Enabled presets (No Display, FPS Only, Horizontal, Custom, Detailed)
    preset = "0,1,2,5,4";

    # FPS limit
    fps_limit = "144,90,60,0";
  };
in
{
  config = lib.mkIf cfg.gaming.enable {
    # Add package
    environment.systemPackages = [ pkgs.mangohud ];

    # Config
    home-manager.users.${config.user.name}.xdg = {
      enable = true;
      configFile = {
        # Presets
        "MangoHud/presets.conf".text = toConfig {
          # Custom 
          "[preset 5]" = {
            table_columns = 3;
            # CPU
            ram = true;
            cpu_temp = true;
            # GPU
            vram = true;
            gpu_name = true;
            gpu_temp = true;
            # Info
            wine = true;
            device_battery = "gamepad";
            frametime = true;
            show_fps_limit = true;
            resolution = true;
            vulkan_driver = true;
          };
        };

        # Default config
        "MangoHud/MangoHud.conf".text = toConfig MangoHud;

        # App overrides
        "MangoHud/cs2.conf".text = toConfig (MangoHud // { fps_limit = "164,0"; });
      };
    };
  };
}

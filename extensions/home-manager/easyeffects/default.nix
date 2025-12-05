{ config, lib, ... }:
let
  cfg = config.services.easyeffects;
  presetOptions = {
    "Dolby Dynamic" = { irs = "dolby-dynamic.irs"; output = "Dolby Dynamic.json"; };
    "Dolby Headphones" = { irs = "dolby-headphones.irs"; output = "Dolby Headphones.json"; };
    "Normalize" = { output = "Normalize.json"; };
    "Clean" = { output = "Clean.json"; };
  };

  mkPreset = name:
    let
      option = presetOptions.${name};
      irs =
        if (builtins.hasAttr "irs" option)
        then { "easyeffects/irs/${option.irs}" = { source = ./irs/${option.irs}; }; }
        else { };
      output = {
        "easyeffects/output/${option.output}" = { source = ./output/${option.output}; };
      };
    in
    irs // output; # Merge

  # Generate autoload files for a preset
  mkAutoload = preset:
    let
      devices = cfg.autoload.${preset};
    in
    lib.foldl'
      (acc: device: acc // {
        "easyeffects/autoload/output/${device}.json" =
          let
            split = lib.splitString ":" device;
          in
          {
            text = builtins.toJSON {
              device = builtins.elemAt split 0;
              device-profile = builtins.elemAt split 1;
              preset-name = preset;
            };
          };
      })
      { }
      devices;
in
{
  options.services.easyeffects = {
    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "Clean" "Normalize" ];
      description = "List of EasyEffects presets to be included";
    };

    autoload = lib.mkOption {
      type = lib.types.attrsOf (lib.types.listOf lib.types.str);
      default = { };
      description = "List of EasyEffects presets to be autoloaded for each device";
      example = {
        "Dolby Dynamic" = [
          # Device_name:Route 
          "alsa_output.pci-0000_04_00.6.HiFi__Speaker__sink:Speaker"
        ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      dataFile =
        # services.easyeffects.presets
        (lib.foldl' (acc: name: acc // mkPreset name) { } cfg.presets)
        // # services.easyeffects.autoload
        (lib.foldl' (acc: preset: acc // mkAutoload preset) { } (builtins.attrNames cfg.autoload));
    };
  };
}

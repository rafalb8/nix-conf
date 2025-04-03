{ config, lib, ... }:
let
  cfg = config.services.easyeffects;
  presetOptions = {
    "Dolby Dynamic" = { irs = "impulse-dynamic.irs"; output = "Dolby Dynamic.json"; };
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
in
{
  options.services.easyeffects = {
    presets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "Clean" "Normalize" ];
      description = "List of EasyEffects presets to be included";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg = {
      enable = true;
      configFile = lib.foldl' (acc: name: acc // mkPreset name) { } cfg.presets;
    };
  };
}

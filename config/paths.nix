{ lib }:
let
  files = builtins.filter (x: x != "paths.nix") (builtins.attrNames (builtins.readDir ./.));
  mapFunc = name:
    {
      name = builtins.elemAt (lib.splitString "." name) 0;
      value = ./. + "/${name}";
    };
in
builtins.listToAttrs (map mapFunc files)

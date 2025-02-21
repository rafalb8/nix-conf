{ lib, pkgs, inputs }:
let
  patcher = script:
    lib.importJSON (pkgs.runCommandLocal "patch" { nativeBuildInputs = with pkgs; [ jq gnused ]; } ''
      bash ${inputs.nvidia-patch}/${script} -j > $out
    '');

  patch = patcher "patch.sh";
  patch-fbc = patcher "patch-fbc.sh";

  driverMod = patch: target: driver:
    driver.overrideAttrs ({ version, preFixup ? "", ... }:
      let
        hasPatch = lib.warnIfNot (builtins.hasAttr version patch)
          ''Patch for driver ${version} not found.''
          false;
      in
      lib.mkIf hasPatch {
        preFixup = preFixup + ''
          sed -i '${patch.${version}}' $out/lib/${target}.${version}
        '';
      });
in
{
  nvenc = driverMod patch "libnvidia-encode.so";
  nvfbc = driverMod patch-fbc "libnvidia-fbc.so";
}

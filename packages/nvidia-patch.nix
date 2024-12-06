{ lib, pkgs, inputs }:
let
  patcher = script:
    lib.importJSON (pkgs.runCommandLocal "patch" { nativeBuildInputs = with pkgs; [ jq gnused ]; } ''
      # Fix https://github.com/keylase/nvidia-patch/pull/865
      sed '/# root check/,/^fi$/d' ${inputs.nvidia-patch}/${script} > patch.sh
      chmod +x patch.sh
      bash patch.sh -j > $out
    '');

  patch = patcher "patch.sh";
  patch-fbc = patcher "patch-fbc.sh";

  driverMod = patch: target: driver:
    driver.overrideAttrs ({ version, preFixup ? "", ... }:
      {
        preFixup = preFixup + ''
          sed -i '${patch.${version}}' $out/lib/${target}.${version}
        '';
      });
in
{
  nvenc = driverMod patch "libnvidia-encode.so";
  nvfbc = driverMod patch-fbc "libnvidia-fbc.so";
}

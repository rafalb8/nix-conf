{ pkgs, package }:
let
  nvidia-patch = pkgs.fetchFromGitHub {
    owner = "keylase";
    repo = "nvidia-patch";
    rev = "refs/heads/master";
    sha256 = "sha256-cPrl/kXXgnIMDm5Phesj+eDXGIsjlhoA1dPOivqSnoM=";
  };
in
package.overrideAttrs (
  { version, preFixup ? "", nativeBuildInputs, ... }:
  {
    nativeBuildInputs = [ pkgs.jq ] ++ nativeBuildInputs;
    preFixup =
      preFixup
      + ''
        bash ${nvidia-patch}/patch.sh -j > patch.json
        bash ${nvidia-patch}/patch-fbc.sh -j > patch-fbc.json
        sed -i $(jq -r '."${version}"' patch.json) $out/lib/libnvidia-encode.so.${version}
        sed -i $(jq -r '."${version}"' patch-fbc.json) $out/lib/libnvidia-fbc.so.${version}
      '';
  }
)

{ pkgs, lib ? pkgs.lib }: {
  # Return last element of the list
  tail = list: builtins.elemAt list (builtins.length list - 1);

  # Translate a Nix value into a shell exported variable declaration.
  toExportShellVars = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") vars);

  # Create C wrapper for script
  wrapScriptBin = name: script: pkgs.stdenv.mkDerivation {
    inherit name;
    phases = [ "buildPhase" ];
    inlineC = ''
      #include <unistd.h>
      int main() {
        char *path = "${pkgs.bash}/bin/bash";
        char *args[] = {"bash", "-p", "${pkgs.writeScript name script}", NULL};
        return execv(path, args);
      }
    '';
    nativeBuildInputs = [ pkgs.gcc ];
    buildPhase = ''
      mkdir -p $out/bin
      gcc -O2 -o $out/bin/${name} -xc - <<< $inlineC
    '';
  };
}

{ pkgs, lib ? pkgs.lib }:
rec {
  # Generate array to be used with imports
  importAll = path:
    map (x: path + "/${x}")
      (
        builtins.filter (x: !(builtins.elem x [ "default.nix" "home.nix" "completions" ]))
          (builtins.attrNames (builtins.readDir path))
      );

  # Return last element of the list
  tail = list: builtins.elemAt list (builtins.length list - 1);

  # Escape and map an attribute set into a list of "KEY=VALUE" strings
  mapShellVars = vars: lib.mapAttrsToList (k: v: "${k}=${lib.escapeShellArg v}") vars;

  # Translate a Nix value into shell exported variable declarations separated by newlines.
  toExportShellVars = vars:
    if vars == { }
    then ""
    else "export " + (lib.concatStringsSep "\nexport " (mapShellVars vars));

  # Turn an attribute set of environment variables into an inline single-line "env K=V " string.
  toEnvPrefix = env:
    if env == { }
    then ""
    else "env " + (lib.concatStringsSep " " (mapShellVars env)) + " ";

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

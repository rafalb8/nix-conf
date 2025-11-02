{ lib }: {
  # Return last element of the list
  tail = list: builtins.elemAt list (builtins.length list - 1);

  # Translate a Nix value into a shell exported variable declaration.
  toExportShellVars = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") vars);
}

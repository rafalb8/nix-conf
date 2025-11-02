{ lib }: {
  # Translate a Nix value into a shell exported variable declaration.
  toExportShellVars = vars: lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "export ${k}=${lib.escapeShellArg v}") vars);
}

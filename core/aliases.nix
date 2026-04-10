{ config, pkgs, ... }:
let
  repl-expr = ''let x = (builtins.getFlake \"$DIR\").nixosConfigurations.${config.networking.hostName}; in { pkgs = x.pkgs; lib = x.lib; config = x.config; }'';
  nix-ext = pkgs.writeShellScriptBin "nix-ext" ''
    if (( EUID == 0 )); then
      echo "\e[1;91mAvoid running nix as root/sudo."
    fi

    DIR="/etc/nixos"
    CMD="$1"
    shift
    case $CMD in
      pull) cd $DIR; git pull;;
      apply) sudo true && nixos-rebuild switch --sudo -Lv "$@";;
      boot) sudo true && nixos-rebuild boot --sudo -Lv "$@";;
      upgrade)
          sudo true # Cache password
          cd $DIR
          \nix flake update
          git add flake.lock && git commit -m "Bump [$(date --rfc-3339=date)]"
          nixos-rebuild boot --sudo -Lv "$@";;
      code) zeditor $DIR "$@";;
      repl) \nix repl --expr "${repl-expr}";;
      *) \nix $CMD "$@";;
    esac
  '';
in
{
  environment.shellInit = ''
    # cat the alias/script
    ccat() { local p=$(type -a "$1" 2>/dev/null | awk '/\// {print $NF; exit}' | tr -d '()'); [ -f "$p" ] && bat "$p"; }
  '';

  environment.shellAliases = {
    # Enable sudo with aliases
    sudo = "sudo ";

    # Main
    du = "du -h";
    df = "df -h";
    xclip = "xclip -selection clipboard";
    fgkill = "jobs -p | grep -o -E ' [0-9]+ ' | xargs -r -n1 pkill -SIGINT -g";
    certcat = "openssl x509 -text -in";
    rsync-cp = "rsync -a --info=progress2 --no-i-r";

    # Nix extension
    nix = "${nix-ext}/bin/nix-ext";

    # Replacements
    cat = "bat";
    ls = "eza";

    # ls
    ll = "ls -lh"; # list
    la = "ls -lah"; # all files list
  };
}

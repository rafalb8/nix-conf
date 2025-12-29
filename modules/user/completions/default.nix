{ config, ... }: {
  programs.zsh = {
    plugins = [{ name = "completions"; src = ./.; }];

    initContent = ''
      # Fix autocomplete for nix extension
      compdef _nix-ext ${config.environment.shellAliases.nix}
    '';
  };
}

{ config, ... }: {
  programs.zsh = {
    plugins = [{ name = "completions"; src = ./.; }];

    initContent = ''
      # Fix autocomplete for nix extension
      compdef _nix-ext ${config.environment.shellAliases.nix}

      # Add command names autocomplete for ccat function
      compdef _command_names ccat
    '';
  };
}

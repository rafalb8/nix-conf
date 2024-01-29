{ config, pkgs, ... }:
{
  # Install neovim globally
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
  };

  home-manager.users.rafalb8.xdg.configFile = {
    "nvim" = {
      source = ../../dotfiles/nvim;
      recursive = true;
    };
  };
}

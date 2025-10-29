{ config, pkgs, ... }:
{
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = config.system.stateVersion;

  home.sessionVariables = {
    DOCKER_BUILDKIT = 1;

    PATH = "$HOME/go/bin:$PATH";

    # Use bat for man
    # https://github.com/sharkdp/bat?tab=readme-ov-file#man
    MANPAGER = ''sh -c 'sed -u -e \"s/\\x1B\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman' '';
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "docker" "docker-compose" "sudo" "history" "dirhistory" ];
      theme = "agnoster";
    };

    sessionVariables = {
      DISABLE_AUTO_UPDATE = true;
      DISABLE_MAGIC_FUNCTIONS = true;
      DISABLE_COMPFIX = true;
    };

    plugins = [
      { name = "completions"; src = ./completions; }
      {
        name = "cmdtime";
        src = pkgs.fetchFromGitHub {
          owner = "tom-auger";
          repo = "cmdtime";
          rev = "main";
          sha256 = "v6wCfNoPXDD3sS6yUYE6lre8Ir1yJcLGoAW3O8sUOCg=";
        };
      }
    ];

    localVariables = {
      HIST_STAMPS = "yyyy-mm-dd";
    };

    shellAliases = {
      mkdir = "mkdir -p";
      dmesg = "sudo dmesg";
    };

    initContent = ''
      # Fix autocomplete for nix extension
      compdef _nix-ext ${config.environment.shellAliases.nix}

      # Smarter completion initialization
      autoload -Uz compinit
      if [[ "$(date +'%j')" = "$(date +'%j' -r  ~/.zcompdump 2>/dev/null)" ]]; then
        compinit -C
      else
        compinit
      fi

      # Catch '--help' and pass it to bat
      alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'
    '';
  };

  programs.git = {
    enable = true;

    aliases = {
      s = "status";
      b = "branch -avv";
      f = "fetch --all --prune";
      cb = "checkout -b";
      co = "checkout";
      l = "log";
      lo = "log --oneline";
      lg = "log --graph";
      log-graph = "log --graph --all --oneline --decorate";
      sps = "!git stash && git pull && git stash pop";
    };

    extraConfig = {
      column.ui = "auto";
      init.defaultBranch = "main";
      help.autocorrect = "prompt";
      commit.verbose = true;

      branch.sort = "-committerdate";
      tag.sort = "version:refname";

      diff = {
        algorithm = "histogram";
        colorMoved = "plain";
        mnemonicPrefix = true;
        renames = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      rerere = {
        enabled = true;
        autoupdate = true;
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      # pull.rebase = true;
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "dell-7050" = { hostname = "dell-7050"; user = "core"; };
    };
  };
}

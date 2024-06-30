{ config, pkgs, ... }:
{
  home-manager.users.${config.user.name} = {
    # The state version is required and should stay at the version you
    # originally installed.
    home.stateVersion = "23.11";

    home.sessionVariables = {
      CGO_ENABLED = 0;
      DOCKER_BUILDKIT = 1;

      PATH = "$HOME/go/bin:$PATH";

      # Use bat for man
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
    };

    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" "docker" "docker-compose" "sudo" "history" "dirhistory" ];
        theme = "agnoster";
      };

      plugins = [
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

        # NixOS aliases
        nix-apply = "sudo " + config.environment.shellAliases.nix-apply;
        nix-upgrade = "sudo -s " + config.environment.shellAliases.nix-upgrade;
      };

      initExtra = ''
        # Functions
        function localip() {
            echo $(ip route get 1.1.1.1 | awk -F"src " 'NR==1{split($2,a," ");print a[1]}')
        }

        # Better help formatting with ? or --help
        function help {
            # Replace ? with --help flag
            if [[ "$BUFFER" =~ '^(-?\w\s?)+\?$' ]]; then
                BUFFER="''${BUFFER::-1} --help"
            fi
    
            # If --help flag found, pipe output through bat
            if [[ "$BUFFER" =~ '^(-?\w\s?)+ --help$' ]]; then
                BUFFER="$BUFFER | bat -p -l help"
            fi
    
            # press enter
            zle accept-line
        }

        # Define new widget in Zsh Line Editor
        zle -N help
        # Bind widget to enter key
        bindkey '^J' help
        bindkey '^M' help
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
        pull.rebase = true;
      };
    };
  };
}

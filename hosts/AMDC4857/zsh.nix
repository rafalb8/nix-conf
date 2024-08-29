{ config, pkgs, ... }:
{
  home.sessionVariables = {
    PATH = "$PATH:${config.home.homeDirectory}/go/bin";

    CGO_ENABLED = 0;
    DOCKER_BUILDKIT = 1;

    # Use bat for man
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  xdg = {
    enable = true;

    configFile = {
      # Add zsh theme
      "zsh" = {
        source = ../../dotfiles/zsh;
        recursive = true;
      };
    };
  };

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "custom";
      plugins = [
        "git"
        "sudo"

        "docker"
        "docker-compose"

        "history"
        "dirhistory"

        "kubectl"
      ];
      custom = "${config.home.homeDirectory}/.config/zsh";
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
      cat = "bat";
      cgo = "CGO_ENABLED=1 go";
      du = "du -h";
      df = "df -h";
      mkdir = "mkdir -p";
      dmesg = "sudo dmesg";
      certcat = "openssl x509 -text -in";
      xclip = "xclip -selection clipboard";
      rsync-cp = "rsync -a --info=progress2 --no-i-r";
      fgkill = "jobs -p | grep -o -E ' [0-9]+ ' | xargs -r -n1 pkill -SIGINT -g";

      # nix
      nix-apply = "home-manager switch";
      nix-upgrade = "nix flake update --flake ~/.config/home-manager && home-manager switch";
      nix-garbage = "nix-collect-garbage -d";
      nix-edit = "code ~/.config/home-manager";

      # kubectl
      kube-merge = "kube-merge(){KUBECONFIG=$1:$2 kubectl config view --flatten}; kube-merge";

      srubuntu = ''sudo -s eval "apt update && apt upgrade -y"'';

      # ls
      ls = "eza";
      ll = "ls -lh"; # list
      la = "ls -lah"; # all files list
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
}

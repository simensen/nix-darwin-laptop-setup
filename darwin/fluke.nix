#
#  Specific system configuration settings for MacBook
#
#  flake.nix
#   └─ ./darwin
#       ├─ default.nix
#       ├─ fluke.nix *
#       └─ ./modules
#           └─ default.nix
#

{ config, pkgs, vars, ... }:

{
  users.users.${vars.user} = {            # MacOS User
    home = "/Users/${vars.user}";
    shell = pkgs.zsh;                     # Default Shell
  };

  networking = {
    computerName = "Fluke";             # Host Name
    hostName = "fluke";
  };

  fonts = {                               # Fonts
    fontDir.enable = true;
  };

  environment = {
    shells = with pkgs; [ zsh ];          # Default Shell
    variables = {                         # Environment Variables
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
    };
    systemPackages = with pkgs; [         # System-Wide Packages
      # Terminal
      #ansible
      git
      #pfetch
      #ranger

      # Doom Emacs
      #emacs
      #fd
      #ripgrep
      tree
    ];
  };

  programs = {
    zsh.enable = true;
  };

  services = {
    nix-daemon.enable = true;             # Auto-Upgrade Daemon
  };

  security.pam.enableSudoTouchIdAuth = true;

  homebrew = {                            # Homebrew Package Manager
    enable = true;
    brewPrefix = "/opt/homebrew/bin";     # Because aarch detection isn't working
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    taps = [
      "homebrew/cask-fonts"
    ];
    brews = [
      #"wireguard-tools"
    ];
    casks = [
      #"moonlight"
      #"plex-media-player"
      "font-hack-nerd-font"
      "font-inter"
      "font-jetbrains-mono-nerd-font"
      "font-lato"
      "font-open-sans"
      "font-roboto"
      "font-source-code-pro"
      #"font-source-sans-pro"
      #"font-source-serif-pro"
    ];
  };

  nix = {
    package = pkgs.nix;
    gc = {                                # Garbage Collection
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      auto-optimise-store = true
      experimental-features = nix-command flakes
    '';
  };

  system = {                              # Global macOS System Settings
    defaults = {
      NSGlobalDomain = {
        KeyRepeat = 1;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      dock = {
        autohide = true;
        autohide-delay = 10.0;
        autohide-time-modifier = 0.0;
        launchanim = true;
        orientation = "bottom";
        showhidden = true;
        tilesize = 16;
        show-process-indicators = false;
        show-recents = false;
        static-only = true;
      };
      finder = {
        QuitMenuItem = false;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };
    activationScripts.postActivation.text = ''sudo chsh -s ${pkgs.zsh}/bin/zsh''; # Set Default Shell
    stateVersion = 4;
  };

  home-manager.users.${vars.user} = {

    home = {
      stateVersion = "22.05";
      
      file.".config/zsh_nix/custom/themes/minimal.zsh-theme".source = ../config/minimal/minimal.zsh;

      packages = with pkgs; [
        coreutils
        curl
        powerline-fonts
        sqlite
        yq
        zsh-git-prompt
      ];
    };

    editorconfig.enable = true;

    programs = {

      bash.enable = true;
      yt-dlp.enable = true;
      go.enable = true;

      btop.enable = true;
      htop.enable = true;
      jq.enable = true;

      direnv.enable = true;
      direnv.nix-direnv.enable = true;

      zsh = {                             # Shell
        enable = true;
        autocd = true;
        enableAutosuggestions = true;
        syntaxHighlighting.enable = true;
        history.size = 10000;

        oh-my-zsh = {                     # Plug-ins
        enable = true;
          theme = "minimal";
          plugins = [ "git" ];
          custom = "$HOME/.config/zsh_nix/custom";
        };

        #initExtra = ''
        #  # Spaceship
        #  source ${pkgs.spaceship-prompt}/share/zsh/site-functions/prompt_spaceship_setup
        #  autoload -U promptinit; promptinit
        #  pfetch
        #'';                               # Theming

        initExtraFirst = ''
          #export PATH=$HOME/.npm-packages/bin:$PATH
          #export PATH=$NIX_USER_PROFILE_DIR/profile/bin:$PATH
          #export PATH=$HOME/bin:$PATH
          #export NVM_DIR="$HOME/.nvm"
          #[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

          # Remove history data we don't want to see
          export HISTIGNORE="pwd:ls:cd"

          if [[ -f "${pkgs.zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh" ]]; then
            . "${pkgs.zsh-git-prompt}/share/zsh-git-prompt/zshrc.sh"
          fi

          mnml_time() {
            echo " %D{%L:%M:%S %p}"
          }

          export MNML_PROMPT=(mnml_status 'mnml_cwd 6 0' git_super_status mnml_keymap)
          export MNML_RPROMPT=()
          export MNML_MAGICENTER=()
          export MNML_INFOLN=()
          TMOUT=1
          TRAPALRM() {
            zle reset-prompt
          }

          setopt TRANSIENT_RPROMPT
          '';

        initExtra = ''

          export ZSH_THEME_GIT_PROMPT_PREFIX=""
          export ZSH_THEME_GIT_PROMPT_SUFFIX=""
          export ZSH_THEME_GIT_PROMPT_SEPARATOR=" "

          #ZSH_THEME_GIT_PROMPT_PREFIX="("
          #ZSH_THEME_GIT_PROMPT_SUFFIX=")"
          #ZSH_THEME_GIT_PROMPT_SEPARATOR="|"
          ZSH_THEME_GIT_PROMPT_BRANCH="\ue0a0%{$fg_bold[magenta]%}"
          ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{●%G%}"
          ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{✖%G%}"
          ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}%{✚%G%}"
          ZSH_THEME_GIT_PROMPT_BEHIND="%{↓%G%}"
          ZSH_THEME_GIT_PROMPT_AHEAD="%{↑%G%}"
          ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[white]%}%{…%G%}"
          ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[green]%}%{✔%G%}"

          unsetopt nomatch

          for file in ~/.setup/.{exports,aliases,functions}; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done

          for file in ~/.setup-custom/.{exports,aliases,functions,zshrc}; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done

          # Load the shell dotfiles, and then some:
          for file in ~/.setup/.{shellrc,projects}.d/*; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done

          for file in ~/.setup-custom/.{shellrc,projects}.d/*; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done
        '';
      };

      git = {
        enable = true;
        userName = "Beau Simensen";
        userEmail = "beau@dflydev.com";
        lfs = {
          enable = true;
        };
        extraConfig = {
          init.defaultBranch = "main";
          core = { 
            #excludesfile = "~/.gitignore_global";
            editor = "vim";
            autocrlf = "input";
            safecrlf = false;
          };
          color.status.untracked = "white normal";
        };
        difftastic = {
          enable = true;
        };
        ignores = [
          "# Compiled source #""
          "###################"
          "*.com"
          "*.class"
          "*.dll"
          "*.exe"
          "*.o"
          "*.so"
          ""
          "# Packages #"
          "############"
          "# it's better to unpack these files and commit the raw source"
          "# git has its own built in compression methods"
          "*.7z"
          "*.dmg"
          "*.gz"
          "*.iso"
          "*.jar"
          "*.rar"
          "*.tar"
          "*.zip"
          ""
          "# Logs and databases #"
          "######################"
          "*.log"
          "*.sql"
          "*.sqlite"
          ""
          "# OS generated files #"
          "######################"
          ".DS_Store"
          ".DS_Store?"
          "._*"
          ".Spotlight-V100"
          ".Trashes"
          "ehthumbs.db"
          "Thumbs.db"
          ""
          "#"
          "#######"
          ""
          "# Vim"
          ".*.sw?"
          ""
          "# PhpStorm"
          ".idea"
          "_ide_helper.php"
          "_ide_helper_models.php"
          ".phpstorm.meta.php"
          ""
          "# vs code"
          ".vscode"
          ""
          "# Sublime Text"
          "*.sublime-project"
          ""
          "# Node"
          "node_modules"
          "npm-debug.log"
          "yarn-error.log"
          ".phpunit-watcher-cache.php"
          ""
          "# phpunit"
          ".phpunit.result.cache"
          ""
          "# composer"
          "auth.json"
          ""
          "# Ignore Beau's env files"
          ".env.beau"
          ""
          "# Ignore act configuration"
          ".actrc"
          ""
          "# TypeScript"
          "*.tsbuildinfo"
          ""
          "# Weird docker artifacts"
          ".bash_history"
          ".composer"
          ".config"
          ".subversion"
        ];
      };

      neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;

        plugins = with pkgs.vimPlugins; [
          # Syntax
          vim-nix
          vim-markdown

          # Quality of life
          vim-lastplace                   # Opens document where you left it
          auto-pairs                      # Print double quotes/brackets/etc.
          vim-gitgutter                   # See uncommitted changes of file :GitGutterEnable

          # File Tree
          nerdtree                        # File Manager - set in extraConfig to F6

          # Customization
          wombat256-vim                   # Color scheme for lightline
          srcery-vim                      # Color scheme for text

          lightline-vim                   # Info bar at bottom
          indent-blankline-nvim           # Indentation lines
        ];

        extraConfig = ''
          syntax enable                             " Syntax highlighting
          colorscheme srcery                        " Color scheme text

          let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ }                                     " Color scheme lightline

          highlight Comment cterm=italic gui=italic " Comments become italic
          hi Normal guibg=NONE ctermbg=NONE         " Remove background, better for personal theme

          set number                                " Set numbers

          nmap <F6> :NERDTreeToggle<CR>             " F6 opens NERDTree
        '';
      };
    };
  };
}

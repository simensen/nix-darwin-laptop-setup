
# #
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
    localHostName = "Fluke";
  };

  environment = {
    #etc = {
      # "hosts" = {
      #   text = ''
      #       ##
      #       # Host Database
      #       #
      #       # localhost is used to configure the loopback interface
      #       # when the system is booting.  Do not change this entry.
      #       ##
      #       127.0.0.1       localhost
      #       255.255.255.255 broadcasthost
      #       ::1             localhost
      #
      #       # reverse-proxy.traefik-development.orb.local
      #       192.168.247.5 prdeploy.test
      #   '';
      #};
    #};
    shells = with pkgs; [ zsh bash ];          # Default Shell
    variables = {                         # Environment Variables
      EDITOR = "${vars.editor}";
      VISUAL = "${vars.editor}";
      NIXPKGS_ALLOW_UNFREE = "1";
    };
    systemPackages = with pkgs; [         # System-Wide Packages
      # Terminal
      #ansible
      #git
      pfetch
      #ranger
      #fh

      # Doom Emacs
      #emacs
      #fd
      #ripgrep
      tree
      #libuvc # No support for aarch64-darwin yet
      #pkg-config
      #libusb1.dev
    ];
  };

  # Note: the `Host linux-builder` section in ssh config above is required
  # for this to work. 
  # To test, run: 
  # nix build --impure --expr '(with import <nixpkgs> { system = "aarch64-linux"; }; runCommand "foo" {} "uname -a > $out")'
  # Or:
  # nix -L build github:tfc/nixos-integration-test-example
  # To SSH directly into the builder, run:
  # $ sudo chmod 644 /etc/nix/builder_ed25519
  # $ ssh builder@linux-builder
  # Then, to revert back to using it with nix build, run:
  # $ sudo chmod 600 /etc/nix/builder_ed25519
  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 4;
    config = {
      virtualisation = {
        darwin-builder = {
          diskSize = 40 * 1024;
          memorySize = 8 * 1024;
        };
        cores = 6;
      };
    };
  };
  # Enable logging for the linux builder
  launchd.daemons.linux-builder = {
    serviceConfig = {
        StandardOutPath = "/var/log/darwin-builder.log";
        StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };

  #services = {
  #  nix-daemon.enable = true;             # Auto-Upgrade Daemon
  #};

  #security.pam.enableSudoTouchIdAuth = true;

  homebrew = {                            # Homebrew Package Manager
    enable = true;
    brewPrefix = "/opt/homebrew/bin";     # Because aarch detection isn't working
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
    };
    brews = [
      #"wireguard-tools"
      #"libuvc" # nixpkgs does not support aarch64-darwin yet
      #"handbrake"
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

      #"adobe-creative-cloud"
      #"audacity"
      "balenaetcher"
      "betterdisplay"
      "bettertouchtool"
      "dropbox"
      "espanso"
      "figma"
      "firefox"
      "makemkv"
      "microsoft-edge"
      "obsidian"
      "openphone"
      "orbstack"
      "rekordbox"
      "rocket"
      "signal"
      "superkey"
      "swiftdefaultappsprefpane"
      "timemachineeditor"
      "vlc"
    ];
    masApps = {
      "1Password for Safari" = 1569813296;
      "AdGuard for Safari" = 1440147259;
      "Adblock Plus" = 1432731683;
      "FakespotSafari" = 1592541616;
      "Fantastical" = 975937182;
      "Focus – Productivity Timer" = 777233759;
      "GoodLinks" = 1474335294;
      "Goodnotes" = 1444383602;
      "Hologram Desktop" = 1529001798;
      "Infuse" = 1136220934;
      "Mona" = 1659154653;
      "Reeder" = 1529448980;
      "Slack" = 803453959;
      "Userscripts" = 1463298887;
    };
  };

  nix = {
    package = pkgs.nix;
    gc = {                                # Garbage Collection
      automatic = true;
      interval.Day = 7;
      options = "--delete-older-than 7d";
    };
    extraOptions = ''
      # auto-optimise-store = true
      experimental-features = nix-command flakes
      extra-platforms = aarch64-darwin
    '';

    settings.extra-trusted-users = [ "@admin" "${vars.user}" ];
  };

  system = {                              # Global macOS System Settings
    primaryUser = "beausimensen";
    defaults = {

      CustomSystemPreferences = {
        NSGlobalDomain = {
          WebAutomaticSpellingCorrectionEnabled = false;
          WebContinuousSpellCheckingEnabled = false;
          WebGrammarCheckingEnabled = false;
        };
        "com.apple.Safari" = {
          "com.apple.Safari.WebAutomaticSpellingCorrectionEnabled" = false;
          "com.apple.Safari.WebContinuousSpellCheckingEnabled" = false;
          "com.apple.Safari.WebGrammarCheckingEnabled" = false;
        };
      };

      #
      # Configuration options can be found here:
      #
      # https://daiderd.com/nix-darwin/manual/
      #

      NSGlobalDomain = {

        # Whether to show all file extensions in Finder. The default is false.
        AppleShowAllExtensions = true;

        # Whether to always show hidden files. The default is false.
        AppleShowAllFiles = false;

        # Whether to automatically switch between light and dark mode.
        # The default is false.
        AppleInterfaceStyleSwitchesAutomatically = false;

        # If you press and hold certain keyboard keys when in a text area, the
        # key’s character begins to repeat. For example, the Delete key
        # continues to remove text for as long as you hold it down.
        #
        # This sets how fast it repeats once it starts.
        KeyRepeat = 3;

        # If you press and hold certain keyboard keys when in a text area, the
        # key’s character begins to repeat. For example, the Delete key
        # continues to remove text for as long as you hold it down.
        #
        # This sets how long you must hold down the key before it starts
        # repeating.
        InitialKeyRepeat = 20;

        # Whether to enable automatic capitalization. The default is true.
        NSAutomaticCapitalizationEnabled = false;

        # Whether to enable smart dash substitution. The default is true.
        NSAutomaticDashSubstitutionEnabled = false;

        # Whether to enable smart period substitution. The default is true.
        NSAutomaticPeriodSubstitutionEnabled = false;

        # Whether to enable smart quote substitution. The default is true.
        NSAutomaticQuoteSubstitutionEnabled = false;

        # Whether to enable automatic spelling correction. The default is true.
        NSAutomaticSpellingCorrectionEnabled = false;

        # Configures the keyboard control behavior. Mode 3 enables full keyboard
        # control.
        AppleKeyboardUIMode = 3;

        # Whether to use expanded save panel by default.
        # The default is false.
        NSNavPanelExpandedStateForSaveMode = true;

        # Whether to use expanded save panel by default.
        # The default is false.
        NSNavPanelExpandedStateForSaveMode2 = true;

        # Whether to save new documents to iCloud by default.
        # The default is true.
        NSDocumentSaveNewDocumentsToCloud = false;

        # Whether to use the expanded print panel by default.
        # The default is false.
        PMPrintingExpandedStateForPrint = true;

        # Whether to use the expanded print panel by default.
        # The default is false.
        PMPrintingExpandedStateForPrint2 = true;

        # Use F1, F2, etc. keys as standard function keys.
        "com.apple.keyboard.fnState" = false;

        # Make a feedback sound when the system volume changed. This setting
        # accepts the integers 0 or 1. Defaults to 1.
        "com.apple.sound.beep.feedback" = 0;

        # Sets the beep/alert volume level from
        # 0.000 (muted) to 1.000 (100% volume).
        "com.apple.sound.beep.volume" = 0.2;
      };
      dock = {
        # Whether to display the appswitcher on all displays or only the main one.
        # The default is false.
        appswitcher-all-displays = false;

        # Whether to automatically hide and show the dock.
        # The default is false.
        autohide = true;

        # Sets the speed of the autohide delay.
        autohide-delay = 10.0;

        # Sets the speed of the animation when hiding/showing the Dock.
        autohide-time-modifier = 0.0;

        # Magnified icon size on hover. The default is 16.
        largesize = 40;

        # Animate opening applications from the Dock. The default is true.
        # launchanim = true;

        # Magnify icon on hover. The default is false
        magnification = true;

        # Position of the dock on screen. The default is “bottom”.
        # orientation = "bottom";

        # Show indicator lights for open applications in the Dock.
        # The default is true.
        #
        # Since we only show open applications, we can turn these off.
        # See show-recents and static-only.
        show-process-indicators = false;

        # Show recent applications in the dock.
        # The default is true.
        show-recents = false;

        # Whether to make icons of hidden applications tranclucent.
        # The default is false.
        showhidden = true;

        # Show only open applications in the Dock.
        # The default is false.
        static-only = true;

        # Size of the icons in the dock.
        # The default is 64.
        tilesize = 32;
      };
      finder = {
        # Whether to always show file extensions.
        # The default is false.
        AppleShowAllExtensions = true;

        # Whether to always show hidden files.
        # The default is false.
        AppleShowAllFiles = true;

        # Change the default search scope. Use “SCcf” to default to current
        # folder. The default is unset (“This Mac”).
        FXDefaultSearchScope = "SCcf";

        # Whether to allow quitting of the Finder.
        # The default is false.
        QuitMenuItem = true;

        # Show path breadcrumbs in finder windows.
        # The default is false.
        ShowPathbar = true;

        # Whether to show the full POSIX filepath in the window title.
        # The default is false.
        _FXShowPosixPathInTitle = true;
      };
      trackpad = {
        # Whether to enable trackpad tap to click.
        # The default is false.
        Clicking = true;

        # Whether to enable trackpad right click.
        # The default is false.
        TrackpadRightClick = true;

        # Whether to enable three finger drag.
        # The default is false.
        TrackpadThreeFingerDrag = true;
      };
      #universalaccess = {
      #  # Set the size of cursor. 1 for normal, 4 for maximum.
      #  # The default is 1.
      #  mouseDriverCursorSize = 2.0;
      #};
    };
    activationScripts.postActivation.text = ''sudo chsh -s ${pkgs.zsh}/bin/zsh''; # Set Default Shell
    stateVersion = 5;
  };

  home-manager.users.${vars.user} = {

    home = {
      shellAliases = {
        setup = "( cd ~/.setup && git remote update && ( git rebase || true ) && sudo bash -c 'env NIXPKGS_ALLOW_UNFREE=1 darwin-rebuild switch --impure --flake .#fluke')";
      };
      sessionVariables = {
        HELLO_BEAU_SESSION_ENV = "What is even up?";
      };
      stateVersion = "24.05";
      
      file.".config/zsh_nix/custom/themes/minimal.zsh-theme".source = ../config/minimal/minimal.zsh;
      file.".config/zsh_nix/custom/plugins/git-prompt.zsh/git-prompt.zsh".source = ../config/git-prompt.zsh/git-prompt.zsh;
      file.".config/zsh_nix/custom/plugins/git-prompt.zsh/git-prompt.plugin.zsh".source = ../config/git-prompt.zsh/git-prompt.plugin.zsh;

      packages = with pkgs; [
        aider-chat
        claude-code
        coreutils
        curl
        graphviz
        id3v2
        lolcat
        lorri
        mas
        openssl
        powerline-fonts
        sqlite
        symfony-cli
        uv
        yq
        #zsh-git-prompt -- broken
        jetbrains.phpstorm
        jetbrains.goland
        jetbrains.idea-ultimate
        jetbrains.rust-rover
        jetbrains.rider
        #jetbrains.jdk -- broken
      ];
    };

    editorconfig.enable = true;

    programs = {
      vscode = {
        enable = true;
      };
      ssh = {
        enable = true;
        addKeysToAgent = "yes";
        extraConfig = ''
        Include ~/.orbstack/ssh/config

        IgnoreUnknown UseKeychain
          UseKeychain yes

        Host linux-builder
          User builder
          Hostname 127.0.0.1
          HostKeyAlias linux-builder
          IdentityFile /etc/nix/builder_ed25519
          Port 31022

        Host pizero2w-0 pizero2w-0.lan.home.simensen.io
          User dietpi
          Hostname pizero2w-0.lan.home.simensen.io
          IdentityFile ~/.ssh/id_ed25519

        Host pi4-0 pi4-0.lan.home.simensen.io
          User dietpi
          Hostname pi4-0.lan.home.simensen.io
          IdentityFile ~/.ssh/id_ed25519

        Host edge edge.lan.home.simensen.io
          User ubnt
          Hostname edge.lan.home.simensen.io
          IdentityFile ~/.ssh/id_ed25519
        '';
      };

      gh = {
        enable = true;
      };

      fzf = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        colors = {
          "fg" = "#4d4d4c,bg:#ffffff,hl:#d7005f";
          "fg+" = "#4d4d4c,bg+:#eeeeee,hl+:#d7005f";
          info = "#4271ae,prompt:#8959a8,pointer:#d7005f";
          marker = "#4271ae,spinner:#4271ae,header:#4271ae";
        };
      };

      bat = {
        enable = true;
        config = {
          pager = "less -FR";
          theme = "GitHub";
        };
      };

      ripgrep.enable = true;

      wezterm = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        extraConfig = ''
          return {
            font = wezterm.font_with_fallback {
              -- 'Dank Mono',
              'JetBrains Mono',
              'Hack Nerd Font Mono',
            },
            font_size = 18,
            line_height = 1.4,
            default_cwd = wezterm.home_dir,
            color_scheme = 'Google (light) (terminal.sexy)',
            bold_brightens_ansi_colors = false,  -- don't keep me from having bold text
            window_background_gradient = {
              colors = { '#ffffff', '#e0e0e8' },
              -- colors = { '#ffffff', '#f0f0f2' },
              -- colors = { '#002b36', '#073642' },
              -- colors = { '#000000', '#3B4351' },
              -- colors = { '#000000', '#242320' },
              -- colors = { '#000000', '#aaaaaa' },
              orientation = 'Vertical',
              blend = 'LinearRgb',
            },

            -- Cursor
            -- Disabling cursor blink makes a _massive_ difference in GPU usage (20% vs 3%).
            -- Therefore, I'll disable it to save energy.
            cursor_blink_rate = 0,

            -- Tab Bar
            hide_tab_bar_if_only_one_tab = true,
            use_fancy_tab_bar = true,

            -- Visual Bell Only
            audible_bell = 'Disabled',
            visual_bell = {
              -- fade_in_duration_ms = 25,
              -- fade_out_duration_ms = 50,
              fade_in_duration_ms = 50,
              fade_out_duration_ms = 75,
              fade_in_function = 'EaseInOut',
              fade_out_function = 'EaseInOut',
              -- fade_in_function = 'EaseIn',
              -- fade_out_function = 'EaseOut',
              -- target = 'CursorColor',
            },
            colors = {
              -- colors = { '#ffffff', '#e0e0e8' },
              visual_bell = '#d0d0df',
            },
            check_for_updates = false,
            front_end = 'WebGpu',
          }
          '';
        };

      bash.enable = true;
      yt-dlp.enable = true;
      go.enable = true;

      btop.enable = true;
      htop.enable = true;
      jq.enable = true;

      direnv.enable = true;
      direnv.nix-direnv.enable = true;
      
      starship.enable = true;
      starship.enableZshIntegration = true;
      starship.enableBashIntegration = false;
      starship.settings = {
        #format = "$all[λ](bright-black) $directory$character";
        #right_format = "$docker_context$container$os";
        format = "$shell$username$hostname$git_branch$git_status$git_commit$fill$battery$status$cmd_duration$all$kubernetes$container$os$line_break[λ](bright-black) $directory$jobs$character";
        right_format = "";
        directory = {
          style = "bright-black";
          truncation_length = 4;
          truncation_symbol = "…/";
          before_repo_root_style = "#cccccc";
          repo_root_style = "bright-black";
          repo_root_format = "[$before_root_path]($before_repo_root_style)[$repo_root]($repo_root_style)[$path]($style)[$read_only]($read_only_style) ";
        };
        container = {
          style = "#cccccc";
        };
        character = {
          #success_symbol = "[❯](purple)";
          #error_symbol = "[❯](red)";
          #vimcmd_symbol = "[❮](green)";
          success_symbol = "[›](purple)";
          error_symbol = "[›](red)";
          vimcmd_symbol = "[‹](green)";
        };
        cmd_duration = {
          format = "[$duration]($style) ";
          style = "yellow";
        };
        docker_context = {
          style = "dimmed blue";
          format = "[$symbol$context]($style) ";
          symbol = " ";
        };
        fill = {
          style = "#eeeeee";
          symbol = " ";
        };
        git_branch = {
          style = "bold #A36AC7";
          symbol = ""; # no space
          format = "[$symbol](bright-black)[$branch(:$remote_branch)]($style) ";
        };
        git_commit = {
          tag_symbol = ""; # no space
        };
        # git_metrics = {
        #   disabled = false;
        # };
        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "black";
          conflicted = "[≡](#FBA922)";
          ahead = "[⇡](blue)";
          behind = "[⇣](blue)";
          diverged = "[⇕](red)";
          untracked = "[…](bright-black)";
          modified = "[+](red)";
          staged = "[+](green)";
          renamed = "[»](red)";
          deleted = "[x](red)";
          stashed = "[…](#FBA922)";

          #format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          #style = "cyan";
          #conflicted = "​";
          #untracked = "​";
          #modified = "​";
          #modified = "[!](green)";
          #staged = "​";
          #renamed = "​";
          #deleted = "​";
          #stashed = "≡";
        };
        python = {
          format = "[$virtualenv]($style) ";
          style = "bright-black";
        };
        os = {
          style = "bright-black";
          disabled = false;
          symbols = {
            Alpine = " ";
            Debian = " ";
            Linux = " ";
            Macos = " ";
            Ubuntu = " ";
            Windows = "󰍲 ";
          };
        };
        php = {
          symbol = " ";
          format = "[$symbol]($style)";
        };
        directory.read_only = " 󰌾";
        golang.symbol = " ";
        nix_shell = {
          format = "[$symbol$state]($style) ";
          symbol = " ";
          impure_msg = "󰫇";
          pure_msg = "󰫈";
        };
        nodejs = {
          format = "[$symbol]($style)";
          symbol = " ";
        };
        package.disabled = true;
        python.symbol = " ";
        rust.symbol = " ";

        hostname = {
          format = "[$hostname]($style) ";
          style = "black";
        };

        username = {
          format = "[$user]($style)[@](#dddddd)";
          style_user = "black";
          style_root = "black";
        };
      };

      zsh = {                             # Shell
        enable = true;
        autocd = true;
        autosuggestion.enable = false;
        syntaxHighlighting.enable = true;
        history.size = 10000;

        initContent = let zshConfigEarlyInit = pkgs.lib.mkOrder 500 ''
          # Remove history data we don't want to see
          export HISTIGNORE="pwd:ls:cd"
        ''; zshConfig = pkgs.lib.mkOrder 1000 ''
          unsetopt nomatch

          for file in ~/{.setup,.setup-custom}/.{exports,aliases,functions}; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done

          # Load the shell dotfiles, and then some:
          for file in ~/{.setup,.setup-custom}/.{shellrc,projects}.d/*; do
              [ -r "$file" ] && [ -f "$file" ] && source "$file"
          done
        ''; in pkgs.lib.mkMerge [ zshConfigEarlyInit zshConfig ];
      };

      git = {
        enable = true;
        userName = "Beau Simensen";
        userEmail = "beau@beausimensen.com";
        lfs = {
          enable = true;
        };
        delta = {
          enable = true;

          options = {
            features = "decorations";
            navigate = true;

            light = true;

            line-numbers = true;

            file-style = "238";
            file-decoration-style = "254 ul";

            line-numbers-minus-style = "167";
            line-numbers-zero-style = "254";
            line-numbers-plus-style = "70";
            line-numbers-left-format = "{nm:>4}┊";
            line-numbers-right-format = "{np:>4}│";
            line-numbers-left-style = "252";
            line-numbers-right-style = "252";

            hunk-header-style = "none";
            hunk-header-line-number-style = "none";
            hunk-header-decoration-style = "none";
          };
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
          ""
          "# Claude Code"
          ".claude/*.local.json"
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
          editorconfig-vim
          papercolor-theme
          onedarkpro-nvim

          # Quality of life
          vim-lastplace                   # Opens document where you left it
          #auto-pairs                      # Print double quotes/brackets/etc.
          vim-gitgutter                   # See uncommitted changes of file :GitGutterEnable

          lightline-vim                   # Info bar at bottom
        ];

        extraConfig = ''
          syntax enable                             " Syntax highlighting
          set number                                " Set numbers
          colorscheme onelight
        '';
      };
    };
  };
}

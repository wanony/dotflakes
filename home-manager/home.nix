{ config, pkgs, inputs, lib, username, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";
    
    # User-specific packages
    packages = with pkgs; [
      # Catppuccin themes
      catppuccin-gtk
      catppuccin-kvantum
      catppuccin-cursors
      
      # Fonts (user level)
      inter
      
      # Python LSP
      python312Packages.python-lsp-server
      python312Packages.pylsp-mypy
      
      # Rust tools
      rust-analyzer
      
      # Terminal enhancements
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-completions
      nix-zsh-completions
    ];
    
    # Dotfiles and config files
    file = {
      # YAGS (Yet Another Generic Startpage) configuration
      ".config/yags/config.json".text = builtins.toJSON {
        title = "Home";
        theme = "catppuccin-mocha";
        searchEngine = "https://search.brave.com/search?q=";
        links = [
          {
            category = "Dev";
            items = [
              { name = "GitHub"; url = "https://github.com"; icon = "github"; }
              { name = "Claude AI"; url = "https://claude.ai"; icon = "message-circle"; }
              { name = "NixOS Search"; url = "https://search.nixos.org/packages"; icon = "package"; }
              { name = "Home Manager Options"; url = "https://home-manager-options.extranix.com"; icon = "home"; }
            ];
          }
          {
            category = "Social";
            items = [
              { name = "Reddit"; url = "https://reddit.com"; icon = "message-square"; }
              { name = "r/unixporn"; url = "https://reddit.com/r/unixporn"; icon = "image"; }
              { name = "r/NixOS"; url = "https://reddit.com/r/nixos"; icon = "box"; }
              { name = "Hacker News"; url = "https://news.ycombinator.com"; icon = "terminal"; }
            ];
          }
          {
            category = "Media";
            items = [
              { name = "YouTube"; url = "https://youtube.com"; icon = "play-circle"; }
              { name = "Spotify"; url = "https://open.spotify.com"; icon = "music"; }
              { name = "Twitch"; url = "https://twitch.tv"; icon = "tv"; }
            ];
          }
          {
            category = "Tools";
            items = [
              { name = "Proton Mail"; url = "https://mail.proton.me"; icon = "mail"; }
              { name = "Bitwarden"; url = "https://vault.bitwarden.com"; icon = "lock"; }
              { name = "Excalidraw"; url = "https://excalidraw.com"; icon = "pen-tool"; }
            ];
          }
        ];
      };
      
      # Wallpapers directory
      "Pictures/Wallpapers/.keep".text = "";
    };
    
    sessionVariables = {
      TERMINAL = "gnome-terminal";
      BROWSER = "firefox";
    };
  };

  # ==========================================================================
  # CATPPUCCIN THEMING
  # ==========================================================================
  
  catppuccin = {
    enable = true;
    flavor = "mocha";  # mocha, macchiato, frappe, or latte
    accent = "mauve";  # blue, flamingo, green, lavender, maroon, mauve, peach, pink, red, rosewater, sapphire, sky, teal, yellow
  };

  # GTK theming
  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-mauve-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        variant = "mocha";
      };
    };
    cursorTheme = {
      name = "catppuccin-mocha-mauve-cursors";
      package = pkgs.catppuccin-cursors.mochaMauve;
      size = 24;
    };
    font = {
      name = "Inter";
      size = 11;
    };
  };

  # Qt theming
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # ==========================================================================
  # GNOME CONFIGURATION & KEYBINDINGS
  # ==========================================================================
  
  dconf.settings = {
    # Custom keybindings
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
      area-screenshot = [ "<Super><Shift>s" ];
    };
    
    # Super+Return = Terminal
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Terminal";
      command = "gnome-terminal";
      binding = "<Super>Return";
    };
    
    # Super+E = File Manager
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "File Manager";
      command = "nautilus";
      binding = "<Super>e";
    };
    
    # Super+B = Browser
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      name = "Browser";
      command = "firefox";
      binding = "<Super>b";
    };
    
    # Super+D = Discord (Equibop)
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      name = "Discord";
      command = "equibop";
      binding = "<Super>d";
    };
    
    # Window management keybindings
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>q" ];
      toggle-maximized = [ "<Super>f" ];
      toggle-fullscreen = [ "<Super><Shift>f" ];
      
      # Workspace switching
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      
      # Move window to workspace
      move-to-workspace-1 = [ "<Super><Shift>1" ];
      move-to-workspace-2 = [ "<Super><Shift>2" ];
      move-to-workspace-3 = [ "<Super><Shift>3" ];
      move-to-workspace-4 = [ "<Super><Shift>4" ];
    };
    
    # Shell keybindings - Super+Space for app search (like Spotlight)
    "org/gnome/shell/keybindings" = {
      toggle-application-view = [ "<Super>a" ];
      toggle-overview = [ "<Super>space" ];  # Spotlight-like search
    };
    
    # GNOME Shell settings
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Terminal.desktop"
        "org.gnome.Nautilus.desktop"
        "equibop.desktop"
      ];
      disable-user-extensions = false;
    };
    
    # Desktop settings
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = true;
      font-antialiasing = "rgba";
      font-hinting = "slight";
    };
    
    # Workspaces
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = true;
    };
    
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 4;
      workspace-names = [ "Code" "Web" "Chat" "Media" ];
    };
    
    # Touchpad settings (if on laptop)
    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
      natural-scroll = true;
      two-finger-scrolling-enabled = true;
    };
  };

  # ==========================================================================
  # ZSH CONFIGURATION WITH COMPLETIONS
  # ==========================================================================
  
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # Completions
    completionInit = ''
      # Initialize completion system
      autoload -Uz compinit
      compinit
      
      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      
      # Menu selection
      zstyle ':completion:*' menu select
      
      # Colors in completion
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      
      # Group completions
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*:descriptions' format '%F{magenta}-- %d --%f'
      
      # Cache completions
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
      
      # Complete . and .. special directories
      zstyle ':completion:*' special-dirs true
      
      # Kill command completion
      zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
      zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
    '';
    
    shellAliases = {
      # Navigation
      ll = "eza -la --icons --git";
      ls = "eza --icons";
      la = "eza -a --icons";
      lt = "eza --tree --icons --level=2";
      cat = "bat";
      cd = "z";  # Use zoxide
      
      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull";
      gd = "git diff";
      gco = "git checkout";
      gb = "git branch";
      glog = "git log --oneline --graph --decorate -10";
      lg = "lazygit";
      
      # Docker
      d = "docker";
      dc = "docker compose";
      dps = "docker ps";
      dpa = "docker ps -a";
      di = "docker images";
      ld = "lazydocker";
      
      # NixOS
      nrs = "sudo nixos-rebuild switch --flake .#nixos";
      nrb = "sudo nixos-rebuild boot --flake .#nixos";
      nrt = "sudo nixos-rebuild test --flake .#nixos";
      nu = "nix flake update";
      ns = "nix search nixpkgs";
      nsh = "nix-shell";
      ncg = "sudo nix-collect-garbage -d";
      
      # System
      ff = "fastfetch";
      c = "clear";
      e = "exit";
      
      # Quick edit
      zshrc = "nvim ~/.zshrc";
      nixconf = "cd /etc/nixos && nvim .";
    };
    
    initContent = ''
      # Initialize zoxide (better cd)
      eval "$(zoxide init zsh)"
      
      # Initialize starship prompt
      eval "$(starship init zsh)"
      
      # Initialize direnv
      eval "$(direnv hook zsh)"
      
      # Rust
      export PATH="$HOME/.cargo/bin:$PATH"
      
      # Go
      export PATH="$HOME/go/bin:$PATH"
      
      # Local binaries
      export PATH="$HOME/.local/bin:$PATH"
      
      # FZF settings with catppuccin colors
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_DEFAULT_OPTS='
        --height 40% 
        --layout=reverse 
        --border rounded
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
      '
      
      # Better history
      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
      
      # Key bindings
      bindkey -e  # Emacs keybindings
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey '^[[3~' delete-char
      
      # Word navigation
      bindkey '^[[1;5C' forward-word   # Ctrl+Right
      bindkey '^[[1;5D' backward-word  # Ctrl+Left
      
      # Welcome message
      if command -v fastfetch > /dev/null 2>&1; then
        fastfetch --logo small
      fi
    '';
    
    history = {
      size = 50000;
      save = 50000;
      path = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
    };
  };

  # ==========================================================================
  # STARSHIP PROMPT - ROUNDY STYLE WITH FULL PATH
  # ==========================================================================
  
  programs.starship = {
    enable = true;
    settings = {
      # Roundy/powerline style prompt
      format = lib.concatStrings [
        "[](mauve)"
        "$os"
        "$username"
        "[](bg:peach fg:mauve)"
        "$directory"
        "[](bg:yellow fg:peach)"
        "$git_branch"
        "$git_status"
        "[](bg:teal fg:yellow)"
        "$python"
        "$rust"
        "$nodejs"
        "$java"
        "$golang"
        "[](bg:blue fg:teal)"
        "$docker_context"
        "$nix_shell"
        "[](fg:blue)"
        "\n$character"
      ];
      
      # Disable default newline
      add_newline = true;
      
      # OS icon
      os = {
        disabled = false;
        style = "bg:mauve fg:base";
        symbols = {
          NixOS = " ";
          Linux = " ";
          Windows = " ";
          Macos = " ";
        };
      };
      
      # Username
      username = {
        show_always = true;
        style_user = "bg:mauve fg:base";
        style_root = "bg:mauve fg:red";
        format = "[ $user ]($style)";
      };
      
      # Directory - FULL PATH
      directory = {
        style = "bg:peach fg:base";
        format = "[ $path ]($style)";
        truncation_length = 0;  # Show full path
        truncate_to_repo = false;  # Don't truncate in git repos
        truncation_symbol = "";
        home_symbol = "~";
        read_only = " 󰌾";
        read_only_style = "bg:peach fg:red";
      };
      
      # Git branch
      git_branch = {
        symbol = " ";
        style = "bg:yellow fg:base";
        format = "[ $symbol$branch ]($style)";
      };
      
      # Git status
      git_status = {
        style = "bg:yellow fg:base";
        format = "[$all_status$ahead_behind]($style)";
        conflicted = " ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        up_to_date = "";
        untracked = "?\${count} ";
        stashed = " ";
        modified = "!\${count} ";
        staged = "+\${count} ";
        renamed = "»\${count} ";
        deleted = "✘\${count} ";
      };
      
      # Python
      python = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$version ]($style)";
      };
      
      # Rust
      rust = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$version ]($style)";
      };
      
      # Node.js
      nodejs = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$version ]($style)";
      };
      
      # Java
      java = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$version ]($style)";
      };
      
      # Go
      golang = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$version ]($style)";
      };
      
      # Docker
      docker_context = {
        symbol = " ";
        style = "bg:blue fg:base";
        format = "[ $symbol$context ]($style)";
        only_with_files = true;
      };
      
      # Nix shell
      nix_shell = {
        symbol = " ";
        style = "bg:blue fg:base";
        format = "[ $symbol$state ]($style)";
        impure_msg = "impure";
        pure_msg = "pure";
      };
      
      # Prompt character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
      
      # Colors (Catppuccin Mocha)
      palette = "catppuccin_mocha";
      palettes.catppuccin_mocha = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };
    };
  };

  # ==========================================================================
  # GIT CONFIGURATION
  # ==========================================================================
  
  programs.git = {
    enable = true;
    settings = {
      user = {
        userName = "wanony";
        userEmail = "whereweat2018@gmail.com";
      };
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        lg = "log --oneline --graph --decorate";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };
    
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      editor = "nvim";
    };
  };

  programs.lazygit = {
    enable = true;
    settings = {
      git = {
        paging = {
	  colorArg = "always";
	  pager = "delta --dark --paging=never";
        };
      };
      os = {
        editPreset = "nvim";
      };
    };
  };

  programs.delta = {
  	enableGitIntegration = true;

      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "Catppuccin Mocha";
      };
};

  # ==========================================================================
  # DEVELOPMENT TOOLS
  # ==========================================================================
  
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # ==========================================================================
  # FILE MANAGER - YAZI
  # ==========================================================================
  
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
      };
    };
  };

  # ==========================================================================
  # FZF
  # ==========================================================================
  
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border rounded"
    ];
  };

  # ==========================================================================
  # BAT (Better cat)
  # ==========================================================================
  
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      style = "numbers,changes,header";
    };
  };

  # ==========================================================================
  # NIRI CONFIGURATION
  # ==========================================================================
  
  xdg.configFile."niri/config.kdl".source = ./niri-config.kdl;
  
  # ==========================================================================
  # EWW STATUS BAR
  # ==========================================================================
  
  programs.eww = {
    enable = true;
    package = pkgs.eww;
    configDir = ./eww;
  };
  
  # ==========================================================================
  # ANYRUN APP LAUNCHER
  # ==========================================================================
  
  xdg.configFile."anyrun/config.ron".text = ''
    Config(
      x: Fraction(0.5),
      y: Fraction(0.3),
      width: Absolute(800),
      height: Absolute(0),
      hide_plugin_info: false,
      close_on_click: true,
      show_results_immediately: true,
      max_entries: 10,
      plugins: [
        "libapplications.so",
        "libsymbols.so",
        "libshell.so",
      ],
    )
  '';
  
  xdg.configFile."anyrun/style.css".source = ./anyrun-style.css;
  
  # ==========================================================================
  # SWAYNOTIFICATIONCENTER
  # ==========================================================================
  
  services.swaync.enable = true;
  catppuccin.swaync.enable = true;
  
  # ==========================================================================
  # SWAYLOCK-EFFECTS
  # ==========================================================================

  programs.swaylock = {
  enable = true;
  package = pkgs.swaylock-effects;
  settings = {
    screenshots = true;
    clock = true;
    effect-blur = "7x5";
    effect-vignette = "0.5:0.5";
    fade-in = "0.2";
    
    timestr = "%H:%M";
    datestr = "%A, %d %B";
    font = "JetBrainsMono Nerd Font";
    
    indicator = true;
    indicator-radius = 100;
    indicator-thickness = 10;
  };
};

catppuccin.swaylock.enable = true;
  
  
  # ==========================================================================
  # SWAYIDLE
  # ==========================================================================
  
  services.swayidle = {
    enable = true;
    events = [
      { event = "before-sleep"; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
    ];
    timeouts = [
      { timeout = 300; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
      { 
        timeout = 600; 
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
        resumeCommand = "${pkgs.niri}/bin/niri msg action power-on-monitors";
      }
    ];
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

}

{ config, pkgs, inputs, lib, username, ... }:

{
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    packages = with pkgs; [
      # Catppuccin themes
      catppuccin-gtk
      catppuccin-kvantum
      catppuccin-cursors

      # Fonts (user level)
      inter

      # Claude Code
      claude-code

      # Terminal enhancements
      zsh-autosuggestions
      zsh-syntax-highlighting
      zsh-completions
      nix-zsh-completions
    ];

    file = {
      # RustDesk autostart — starts on XFCE login so this machine is always accessible
      ".config/autostart/rustdesk.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=RustDesk
        Exec=flatpak run com.rustdesk.RustDesk
        Hidden=false
        Comment=RustDesk remote desktop (always-on for remote access)
      '';

      # YAGS startpage configuration
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

      # Wallpapers directory placeholder
      "Pictures/Wallpapers/.keep".text = "";
    };

    sessionVariables = {
      TERMINAL = "xfce4-terminal";
      BROWSER = "floorp";
    };
  };

  # ==========================================================================
  # CATPPUCCIN THEMING
  # ==========================================================================

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

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

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # ==========================================================================
  # GPG AGENT
  # ==========================================================================

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  # ==========================================================================
  # MPD — Music Player Daemon
  # ==========================================================================

  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire Output"
      }
      auto_update "yes"
    '';
  };

  # ==========================================================================
  # ZSH CONFIGURATION
  # ==========================================================================

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    completionInit = ''
      autoload -Uz compinit
      compinit

      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*:descriptions' format '%F{magenta}-- %d --%f'
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "$HOME/.zsh/cache"
      zstyle ':completion:*' special-dirs true
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
      cd = "z";

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

      # NixOS — point to this host
      nrs = "sudo nixos-rebuild switch --flake ~/dotflakes#homelab";
      nrb = "sudo nixos-rebuild boot --flake ~/dotflakes#homelab";
      nrt = "sudo nixos-rebuild test --flake ~/dotflakes#homelab";
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
      nixconf = "cd ~/dotflakes && nvim .";
    };

    initContent = ''
      eval "$(zoxide init zsh)"
      eval "$(starship init zsh)"
      eval "$(direnv hook zsh)"

      export PATH="$HOME/.local/bin:$PATH"

      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_DEFAULT_OPTS='
        --height 40%
        --layout=reverse
        --border rounded
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
        --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
      '

      setopt HIST_IGNORE_ALL_DUPS
      setopt HIST_SAVE_NO_DUPS
      setopt HIST_REDUCE_BLANKS
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY

      bindkey -e
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey '^[[3~' delete-char
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word

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
  # STARSHIP PROMPT
  # ==========================================================================

  programs.starship = {
    enable = true;
    settings = {
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
        "$nix_shell"
        "[](fg:teal)"
        "\n$character"
      ];

      add_newline = true;

      os = {
        disabled = false;
        style = "bg:mauve fg:base";
        symbols = {
          NixOS = " ";
          Linux = " ";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:mauve fg:base";
        style_root = "bg:mauve fg:red";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "bg:peach fg:base";
        format = "[ $path ]($style)";
        truncation_length = 0;
        truncate_to_repo = false;
        truncation_symbol = "";
        home_symbol = "~";
        read_only = " 󰌾";
        read_only_style = "bg:peach fg:red";
      };

      git_branch = {
        symbol = " ";
        style = "bg:yellow fg:base";
        format = "[ $symbol$branch ]($style)";
      };

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

      nix_shell = {
        symbol = " ";
        style = "bg:teal fg:base";
        format = "[ $symbol$state ]($style)";
        impure_msg = "impure";
        pure_msg = "pure";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

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
        name = "wanony";
        email = "whereweat2018@gmail.com";
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
  # NEOVIM WITH PLUGINS
  # ==========================================================================

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      # LSP and completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-cmdline
      luasnip
      cmp_luasnip
      friendly-snippets

      # Treesitter for syntax highlighting
      nvim-treesitter.withAllGrammars

      # Git integration
      gitsigns-nvim
      vim-fugitive

      # File navigation
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-web-devicons

      # UI enhancements
      lualine-nvim
      bufferline-nvim
      indent-blankline-nvim

      # Color scheme
      catppuccin-nvim

      # Auto pairs
      nvim-autopairs

      # Comment plugin
      comment-nvim

      # Which-key for keybinding help
      which-key-nvim

      # Formatting
      conform-nvim
    ];

    initLua = ''
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 2
      vim.opt.tabstop = 2
      vim.opt.smartindent = true
      vim.opt.wrap = false
      vim.opt.swapfile = false
      vim.opt.backup = false
      vim.opt.undofile = true
      vim.opt.hlsearch = false
      vim.opt.incsearch = true
      vim.opt.termguicolors = true
      vim.opt.scrolloff = 8
      vim.opt.signcolumn = "yes"
      vim.opt.updatetime = 50
      vim.opt.colorcolumn = "100"
      vim.opt.cursorline = true
      vim.opt.mouse = "a"
      vim.opt.clipboard = "unnamedplus"
      vim.g.mapleader = " "

      require("catppuccin").setup({
        flavour = "mocha",
        integrations = {
          treesitter = true,
          telescope = true,
          gitsigns = true,
          cmp = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")

      require("nvim-treesitter.configs").setup({
        highlight = { enable = true },
        indent = { enable = true },
      })

      -- Completion setup
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })
      require("telescope").load_extension("fzf")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})

      require("lualine").setup({
        options = { theme = "catppuccin" },
      })

      require("bufferline").setup({
        options = { separator_style = "slant" },
      })

      require("gitsigns").setup()
      require("nvim-autopairs").setup()
      require("Comment").setup()
      require("which-key").setup()

      require("conform").setup({
        formatters_by_ft = {
          nix = { "nixpkgs_fmt" },
        },
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
      })

      vim.keymap.set("n", "<leader>e", vim.cmd.Ex)
      vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
      vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
      vim.keymap.set("n", "<C-d>", "<C-d>zz")
      vim.keymap.set("n", "<C-u>", "<C-u>zz")
      vim.keymap.set("n", "n", "nzzzv")
      vim.keymap.set("n", "N", "Nzzzv")
    '';
  };

  # ==========================================================================
  # FILE MANAGER — YAZI
  # ==========================================================================

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
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
  # BAT
  # ==========================================================================

  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin Mocha";
      style = "numbers,changes,header";
    };
  };

  programs.home-manager.enable = true;
}

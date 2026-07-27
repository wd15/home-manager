{ config, pkgs, ... }:
let
  vivaldi-fixed = pkgs.symlinkJoin {
    name = "vivaldi-fixed";
    paths = [ (pkgs.vivaldi.override { proprietaryCodecs = true; enableWidevine = true; }) ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      # Wrap the binaries
      wrapProgram $out/bin/vivaldi \
        --run 'unset DBUS_SESSION_BUS_ADDRESS'

      if [ -e $out/bin/vivaldi-stable ]; then
        wrapProgram $out/bin/vivaldi-stable \
          --run 'unset DBUS_SESSION_BUS_ADDRESS'
      fi

      # Strip out the original desktop files entirely so they never collide with Home Manager
      rm -rf $out/share/applications
    '';
  };

  google-chrome-fixed = pkgs.symlinkJoin {
    name = "google-chrome-fixed";
    paths = [ pkgs.google-chrome ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/google-chrome-stable --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

  obsidian-fixed = pkgs.symlinkJoin {
    name = "obsidian-fixed";
    paths = [ pkgs.obsidian ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/obsidian --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

  code-cursor-fixed = pkgs.symlinkJoin {
    name = "code-cursor-fixed";
    paths = [ pkgs.code-cursor ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cursor --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

in
{
  # 1. Modern Import: Let Home Manager handle module loading.
  # Ensure ./bash.nix, ./emacs.nix, and ./shell.nix define a top-level module
  # (e.g., `{ pkgs, ... }: { ... }`) rather than just returning a value.
  imports = [
    ./bash.nix
    ./emacs.nix
    ./shell.nix
    # ./sway.nix
    ./hyprland.nix
  ];

  # 2. Allow Unfree: Redundant if set in flake.nix, but good safety here.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.username = "wd15";
  home.homeDirectory = "/home/wd15";
  home.stateVersion = "24.05";

  # 3. Targets: Essential for non-NixOS systems (handles XDG paths, etc.)
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  # ADD THIS BLOCK: Map web protocols to your xdg.desktopEntries.vivaldi-stable entry
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/about" = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "vivaldi-stable.desktop";
    };
  };

  # 4. Package Definitions (Cleaned up)
  home.packages = with pkgs; [
    google-cloud-sdk

    # Core Utilities
    git
    git-lfs
    coreutils
    bashInteractive
    jq
    pwgen
    timer
    nixpkgs-review
    ansible
    nix-ld

    # Programming / Runtimes
    jdk
    nodejs
    uv
    poetry
    micromamba
    # Note: Haskell package moved to 'let' below if you need specific config,
    # otherwise install 'ghc' directly here.

    # Applications
    vivaldi-fixed
    google-chrome-fixed
    obsidian-fixed
    code-cursor-fixed
    firefox
    zotero
    inkscape
    gnuplot

    # Document Processing
    pandoc
    imagemagick
    texlive.combined.scheme-full

    # Python Environment (custom definition below)
    (python313.withPackages (p: [
      p.jupyter
      p.ipython
      p.jupyterlab
      p.notebook
      p.traitlets
      p.ipykernel
      p.matplotlib
      p.pandas
    ]))

    # Haskell Environment (custom definition)
    (haskellPackages.ghcWithPackages (ps: with ps; [
      monad-par mtl split stack lens ihaskell
    ]))

    github-cli

    hyprpaper
  ];

  # 5. File Management
  home.file = {
    ".config/git/config".source = ./dotfiles/gitconfig;
    ".commit-template.txt".source = ./dotfiles/commit-template.txt;
    ".gitignore".source = ./dotfiles/gitignore;
    ".git-completion.bash".source = ./dotfiles/git-completion.bash;
    ".ssh/config".source = ./dotfiles/ssh-config;
    ".signature.txt".source = ./dotfiles/signature.txt;

    ".mambarc".text = ''
      channels:
        - conda-forge
      always_yes: true
      proxy_servers:
        http:  http://qv74thju04.proxy.cloudflare-gateway.com
        https: https://qv74thju04.proxy.cloudflare-gateway.com:443

    '';
  };

  # 6. Session Variables
  home.sessionVariables = {
    EDITOR = "emacs -nw";
    # Fix for micromamba shell initialization
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";
    BROWSER = "vivaldi";
  };

  # 7. Program Configurations
  programs.home-manager.enable = true;

  # Browsers
  programs.firefox.enable = true;

  # Tmux
  # programs.tmux = {
  #   enable = true;
  #   mouse = true;
  #   extraConfig = ''
  #     # Copy tmux buffer to X clipboard
  #     bind C-w run -b "tmux show-buffer | ${pkgs.xclip}/bin/xclip -i"
  #   '';
  # };

# Tmux
  programs.tmux = {
    enable = true;
    mouse = true;
    extraConfig = ''
      # Copy tmux buffer to Wayland clipboard
      bind C-w run -b "tmux show-buffer | ${pkgs.wl-clipboard}/bin/wl-copy"
    '';
  };

  # 8. Extra Profile Commands (Desktop Database Update)
  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  # 2. The GUI Shortcut Override
  xdg.desktopEntries = {
    vivaldi-stable = {
      name = "Vivaldi";
      genericName = "Web Browser";
      # By just saying "vivaldi", we force the GUI to use the wrapped binary from your PATH
      exec = "${vivaldi-fixed}/bin/vivaldi %U";
      icon = "vivaldi";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };

    google-chrome = {
      name = "Google Chrome";
      genericName = "Web Browser";
      exec = "${google-chrome-fixed}/bin/google-chrome-stable %U";
      icon = "google-chrome";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };

    obsidian = {
      name = "Obsidian";
      genericName = "Knowledge Base";
      exec = "${obsidian-fixed}/bin/obsidian %U";
      icon = "obsidian";
      terminal = false;
      categories = [ "Office" ];
    };

    cursor = {
      name = "Cursor";
      genericName = "Text Editor";
      exec = "${code-cursor-fixed}/bin/cursor %U";
      icon = "cursor";
      terminal = false;
      categories = [ "Development" "TextEditor" ];
    };

  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };


}

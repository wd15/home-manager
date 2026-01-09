{ config, pkgs, ... }:

{
  # 1. Modern Import: Let Home Manager handle module loading.
  # Ensure ./bash.nix, ./emacs.nix, and ./shell.nix define a top-level module
  # (e.g., `{ pkgs, ... }: { ... }`) rather than just returning a value.
  imports = [
    ./bash.nix
    ./emacs.nix
    ./shell.nix
  ];

  # 2. Allow Unfree: Redundant if set in flake.nix, but good safety here.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.username = "wd15";
  home.homeDirectory = "/home/wd15";
  home.stateVersion = "24.05";

  # 3. Targets: Essential for non-NixOS systems (handles XDG paths, etc.)
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;

  # 4. Package Definitions (Cleaned up)
  home.packages = with pkgs; [
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
    obsidian
    firefox
    google-chrome
    vivaldi
    zotero
    inkscape
    gnuplot
    code-cursor

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
  };

  # 7. Program Configurations
  programs.home-manager.enable = true;

  # Browsers
  programs.firefox.enable = true;
  programs.vivaldi.enable = true;

  # Tmux
  programs.tmux = {
    enable = true;
    mouse = true;
    extraConfig = ''
      # Copy tmux buffer to X clipboard
      bind C-w run -b "tmux show-buffer | ${pkgs.xclip}/bin/xclip -i"
    '';
  };

  # 8. Extra Profile Commands (Desktop Database Update)
  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };
}

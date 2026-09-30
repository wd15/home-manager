{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Core Utilities
    git
    git-lfs
    coreutils
    bashInteractive
    timer
    jq
    pwgen
    sqlite
    nixpkgs-review

    # Terminal Navigation & Search
    ripgrep
    fd
    fzf
    htop
    tree

    # Version Control & AI
    github-cli
    jujutsu
    aicommit2

    # Project / Environment Managers
    uv
    poetry
    micromamba
  ];
}

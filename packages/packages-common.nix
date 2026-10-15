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

    # Python Environment (Heavy for desktop)
    (python313.withPackages (p: [
      p.jupyter
      p.ipython
      p.jupyterlab
      p.notebook
      p.traitlets
      p.ipykernel
      p.matplotlib
      p.pandas
      p.jupyter-client
      p.ipykernel
      p.jupytext
    ]))


  ];
}

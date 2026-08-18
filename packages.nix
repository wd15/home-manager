# ============================================================
# packages.nix
# Plain CLI tools + dev-runtime package list. Pure data --
# easiest file to scan/edit without touching Nix expressions.
# ============================================================
{ pkgs, aicommit2Pkg, ... }:

{
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
    github-cli

    # Programming / Runtimes
    jdk
    nodejs
    uv
    poetry
    micromamba

    # Desktop apps (non-browser)
    zotero
    inkscape
    gnuplot
    hyprpaper
    grimblast

    # Document Processing
    pandoc
    imagemagick
    texlive.combined.scheme-full

    # Python Environment
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

    # Haskell Environment
    (haskellPackages.ghcWithPackages (ps: with ps; [
      monad-par mtl split stack lens ihaskell
    ]))

    # Other
    opencommit
    mermaid-cli
    jujutsu
    aicommit2Pkg

  ];
}

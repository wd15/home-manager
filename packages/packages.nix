{ pkgs, ... }:

{
  imports = [ ./packages-common.nix ];

  home.packages = with pkgs; [
    # Cloud & DevOps
    google-cloud-sdk
    ansible
    nix-ld

    # Programming / Runtimes
    jdk
    nodejs

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
    quarto

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
    ]))

    # Haskell Environment
    (haskellPackages.ghcWithPackages (ps: with ps; [
      monad-par mtl split stack lens ihaskell
    ]))

    # Other Desktop
    opencommit
    mermaid-cli
    alpine
    zen-browser
    aspell
    aspellDicts.en

    # Add this to your existing list of packages
    pkgs.nerd-fonts.fira-code
  ];
}

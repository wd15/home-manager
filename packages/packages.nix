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

    emacs-all-the-icons-fonts
    nerd-fonts.fira-code
    nerd-fonts.symbols-only

    ltex-ls-plus
  ];
}

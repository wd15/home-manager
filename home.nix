# TODO:
# - set default applicatioins via xdg
#   - obsidian
#   - emacs
#   - firefox as default browser
#   - google chrome
#   - tmux

{ config, pkgs, ... }:
let
  bashsettings = import ./bash.nix pkgs;
  bashScripts = import ./shell.nix pkgs;
  emacssettings = import ./emacs.nix pkgs;
  ghc = pkgs.haskellPackages.ghcWithPackages (ps: with ps; [
    monad-par mtl split stack lens ihaskell
  ]);
  python = pkgs.python310.withPackages (p: [
    p.jupyter
    p.ipython
    p.jupyterlab
    p.notebook
    p.traitlets
    p.numpy
    p.ipykernel
    p.matplotlib
    p.pandas
    p.jupyter
  ]);
in
{
  nixpkgs.config.allowUnfreePredicate = (pkg: true);
  home.username = "wd15";
  home.homeDirectory = "/home/wd15";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.05"; # Please read the comment before changing.

  home.packages = [
    pkgs.git
    pkgs.obsidian
    pkgs.firefox
    pkgs.google-chrome
    pkgs.git-lfs
    pkgs.xournal
    pkgs.texlive.combined.scheme-full
    ghc
    # See https://nixos.wiki/wiki/Python#micromamba and
    # https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html
    # To use:
    #
    #     $ eval "$(micromamba shell hook -s bash)"
    #     $ micromamba activate my-environment
    #
    # remove env:
    #
    #     $ micromamba env remove -n my-environment
    #
    pkgs.micromamba
    pkgs.poetry
    pkgs.vivaldi
    pkgs.pwgen
    pkgs.coreutils
    pkgs.bashInteractive
    pkgs.jdk
    pkgs.jq
    python
    pkgs.nixpkgs-review
    pkgs.nodejs
    pkgs.timer
    pkgs.zotero
    pkgs.pandoc
    pkgs.inkscape
    pkgs.imagemagick
    pkgs.ansible
    pkgs.uv
    # pkgs.ihaskell
  ] ++ bashScripts;

  home.file = {
    ".config/git/config".source = dotfiles/gitconfig;
    ".commit-template.txt".source = dotfiles/commit-template.txt;
    ".gitignore".source = dotfiles/gitignore;
    ".git-completion.bash".source = dotfiles/git-completion.bash;
    ".ssh/config".source = dotfiles/ssh-config;
    ".signature.txt".source = dotfiles/signature.txt;
    ".mambarc".text = ''
      channels:
        - conda-forge
      always_yes: true
      custom_channels:
        conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge
    '';
      # channels:
      #   - conda-forge
      # always_yes: true

    # this file shouldn't be included as it keys
    # ".config/nix/nix.conf".source = dotfiles/nix.conf;


  };


  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/wd15/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    EDITOR = "emacs -nw";
  };


  programs.bash = bashsettings;
  programs.emacs = emacssettings;
  programs.tmux.enable = true;
  programs.tmux.mouse = true;
  programs.tmux.extraConfig = ''
    # Copytmux buffer to X clipboard
    # run -b runs a shell command in background
    # bind C-w run -b "tmux show-buffer | xclip -selection clipboard -i"
    bind C-w run -b "tmux show-buffer | xclip -i"
  '';
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox;
  programs.vivaldi.enable = true;
  programs.vivaldi.package = pkgs.vivaldi;
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  programs.home-manager.enable = true;
  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';



}

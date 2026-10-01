{ config, pkgs, lib, ... }:

{
  imports = [
    ../shell/zsh.nix
    ../emacs/emacs.nix
    ../programs/git-ssh.nix
    ../programs/jujutsu.nix
  ];

  home.username = "wd15";
  home.stateVersion = "24.05";
  targets.genericLinux.enable = true;
  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";
  };

  programs.tmux = {
    enable = true;
    mouse = true;
  };

}

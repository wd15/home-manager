{ config, pkgs, lib, ... }:
{
  imports = [
    ./bash.nix
    ./emacs.nix
    ./git-ssh.nix
    ./packages-cluster.nix
  ];

  home.username = "wd15";
  home.homeDirectory = "/users/wd15";
  home.stateVersion = "24.05";

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";
    XDG_CACHE_HOME = "/toolbox/wd15/.cache";
  };

  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
  };

  home.file.".bashrc".enable = false;
  home.file.".bash_profile".enable = false;
  home.file.".profile".enable = false;

  home.file.".bashrc-hm".source = config.home.file.".bashrc".source;
  home.file.".bash_profile-hm".source = config.home.file.".bash_profile".source;
  home.file.".profile-hm".source = config.home.file.".profile".source;
}

# ============================================================
# home.nix
# Core glue only: identity, imports, session vars, small
# program toggles that don't warrant their own file.
# ============================================================
{ config, pkgs, ... }:

{
  imports = [
    ./bash.nix
    ./emacs.nix
    ./shell.nix
    ./hyprland.nix
    ./browsers.nix
    ./packages.nix
    ./git-ssh.nix
  ];

  # NOTE: if flake.nix already sets nixpkgs.config.allowUnfree = true globally,
  # this line is redundant EXCEPT that it also permits insecure packages
  # (predicate = true for everything, not just unfree). Confirm you actually
  # need the insecure-package allowance; if not, drop this and rely on the
  # flake-level allowUnfree instead.
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home.username = "wd15";
  home.homeDirectory = "/home/wd15";
  home.stateVersion = "24.05";

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";
    BROWSER = "vivaldi";
  };

  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    extraConfig = ''
      # Copy tmux buffer to Wayland clipboard
      bind C-w run -b "tmux show-buffer | ${pkgs.wl-clipboard}/bin/wl-copy"

      # Force tmux to grab fresh Wayland variables every time you attach
      set-option -g update-environment "DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_SESSION_TYPE SSH_AUTH_SOCK"
    '';
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };
}

# ============================================================
# home-cluster.nix  (full file, replaces previous version)
#
# Reuses the shared bash.nix (with isCluster=true, via
# extraSpecialArgs in flake.nix) as the single source of truth --
# no more duplicated alias/prompt content. programs.bash still
# writes ~/.bashrc as a normal Home-Manager symlink internally;
# an activation script then COPIES that generated content to
# ~/.bashrc-hm, a safe filename nothing reads before the namespace
# bootstrap. The permanent, hand-written ~/.bashrc (outside Nix's
# control -- see bottom of this file) sources .bashrc-hm once /nix
# is resolvable.
# ============================================================
{ config, pkgs, lib, ... }:

{
  imports = [
    ./bash.nix          # shared with laptop; isCluster comes from specialArgs
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

  # ---- Suppress Home Manager writing .bashrc/.bash_profile/.profile ----
  # Confirmed via Home Manager's own FAQ + source (modules/files.nix):
  # home.file."<name>".enable = false suppresses the actual write, but
  # the generated content is still available via .source -- so we can
  # redirect it to a safe filename with zero copying/activation-script
  # complexity, and Home Manager will never again try to clobber the
  # permanent hand-written login files (no more backup-flag fights).
  home.file.".bashrc".enable = false;
  home.file.".bash_profile".enable = false;
  home.file.".profile".enable = false;

  # Redirect programs.bash's generated content to safe filenames that
  # nothing reads until AFTER the namespace bootstrap (permanent,
  # hand-written ~/.bashrc etc. -- see bottom of this file) has made
  # /nix resolvable.
  home.file.".bashrc-hm".source = config.home.file.".bashrc".source;
  home.file.".bash_profile-hm".source = config.home.file.".bash_profile".source;
  home.file.".profile-hm".source = config.home.file.".profile".source;

  # nix.settings intentionally omitted -- see README, inert on this store.
}

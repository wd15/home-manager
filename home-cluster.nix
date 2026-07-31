
# ============================================================
# home-cluster.nix
# ============================================================
{ config, pkgs, ... }:

{
  imports = [
    ./bash-cluster.nix
    ./emacs.nix              # headless-safe as-is
    ./git-ssh.nix            # shared: git/ssh dotfiles + keychain + mambarc
    ./packages-cluster.nix
  ];

  home.username = "wd15";
  home.homeDirectory = "/users/wd15";   # confirmed via mr-french, NOT /home/wd15
  home.stateVersion = "24.05";

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";

    # Keep Nix's cache off NFS-backed $HOME (confirmed: /users/wd15 is
    # genie:/vol0/home/wd15, network-mounted, 98% full) and onto local
    # block storage instead.
    XDG_CACHE_HOME = "/toolbox/wd15/.cache";
  };

  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    # No Wayland clipboard binding -- no compositor on a compute node.
  };

  # nix.settings intentionally omitted: Home Manager's nix.settings
  # configures whatever Nix install Home Manager itself runs under.
  # On the cluster, the actual Nix in use is a separate statically-linked
  # binary (/toolbox/wd15/opt/bin/nix) using its own private mount-namespace
  # trick (confirmed via `strings` + tryUnshareFilesystemEv) to present
  # /toolbox/wd15/opt/nix as /nix. That binary reads ~/.config/nix/nix.conf
  # directly, entirely outside Home Manager's control -- so nix.settings
  # here would be inert. (On the laptop, by contrast, Home Manager's own
  # Nix settings ARE meaningful, since it's a standard install.)
}

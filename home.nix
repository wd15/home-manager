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
    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ] ++ bashScripts;

  home.file = {
    ".config/git/config".source = dotfiles/gitconfig;
    ".commit-template.txt".source = dotfiles/commit-template.txt;
    ".gitignore".source = dotfiles/gitignore;
    ".git-completion.bash".source = dotfiles/git-completion.bash;
    ".ssh/config".source = dotfiles/ssh-config;

    # this file shouldn't be included as it keys
    # ".config/nix/nix.conf".source = dotfiles/nix.conf;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
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
  programs.firefox.enable = true;
  programs.firefox.package = pkgs.firefox;
  targets.genericLinux.enable = true;
  xdg.mime.enable = true;
  programs.home-manager.enable = true;
  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';



}

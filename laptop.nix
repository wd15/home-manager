{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ./shell.nix
    ./hyprland.nix
    ./browsers.nix
    ./packages.nix
    ./workspace-icons.nix
  ];

  home.homeDirectory = "/home/wd15";

  home.sessionVariables = {
    BROWSER = "vivaldi";
  };

  nixpkgs.config.allowUnfreePredicate = pkg: true;

  programs.vscode = {
    enable = true;
    package = pkgs.vscode-fhs;
  };

  services.emacs = {
    enable = true;
    client.enable = true;
  };

  programs.tmux.extraConfig = ''
    # Copy tmux buffer to Wayland clipboard
    bind C-w run -b "tmux show-buffer | ${pkgs.wl-clipboard}/bin/wl-copy"
    # Force tmux to grab fresh Wayland variables every time you attach
    set-option -g update-environment "DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_SESSION_TYPE SSH_AUTH_SOCK"
  '';

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
  age.secrets.opencommit-api-key.file = ./secrets/opencommit-api-key.age;

  home.activation.opencommitConfig = lib.hm.dag.entryAfter ["agenixInstall"] ''
    cat > ${config.home.homeDirectory}/.opencommit <<EOF
    OCO_AI_PROVIDER=gemini
    OCO_MODEL=gemini-3.5-flash-lite
    OCO_API_KEY=$(cat ${config.age.secrets.opencommit-api-key.path})
    EOF
    chmod 600 ${config.home.homeDirectory}/.opencommit
  '';
}

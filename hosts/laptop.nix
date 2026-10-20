{ config, pkgs, lib, ... }:
{
  imports = [
    ./common.nix
    ../shell/shell.nix
    ../desktop/hyprland.nix
    ../packages/packages.nix
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

  programs.tmux.extraConfig = ''
    # Copy tmux buffer to Wayland clipboard
    bind C-w run -b "tmux show-buffer | ${pkgs.wl-clipboard}/bin/wl-copy"
    # Force tmux to grab fresh Wayland variables every time you attach
    set-option -g update-environment "DISPLAY WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_SESSION_TYPE SSH_AUTH_SOCK"
  '';

  age.identityPaths = [ "${config.home.homeDirectory}/.ssh/agenix" ];
  age.secrets.opencommit-api-key.file = ../secrets/opencommit-api-key.age;
  age.secrets.aic2-api-key.file = ../secrets/aic2-api-key.age;

  home.activation.opencommitConfig = lib.hm.dag.entryAfter ["agenixInstall"] ''
    cat > ${config.home.homeDirectory}/.opencommit <<EOF
    OCO_AI_PROVIDER=gemini
    OCO_MODEL=gemini-3.5-flash-lite
    OCO_API_KEY=$(cat ${config.age.secrets.opencommit-api-key.path})
    EOF
    chmod 600 ${config.home.homeDirectory}/.opencommit
  '';

  home.activation.aic2Config = lib.hm.dag.entryAfter ["agenixInstall" "reloadSystemd"] ''
    export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    ${pkgs.systemd}/bin/systemctl --user start agenix.service || true
    mkdir -p ${config.home.homeDirectory}/.config/aicommit2
    cat > ${config.home.homeDirectory}/.config/aicommit2/config.ini <<EOF
[GEMINI]
key=$(cat ${config.age.secrets.aic2-api-key.path})
model[]=gemini-3-flash-preview
EOF
    chmod 600 ${config.home.homeDirectory}/.config/aicommit2/config.ini
  '';



  fonts.fontconfig.enable = true;

  services.emacs = {
    enable = true;
    startWithUserSession = "graphical";
  };
}

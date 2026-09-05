{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ./packages-cluster.nix
  ];

  home.homeDirectory = "/users/wd15";

  home.sessionVariables = {
    XDG_CACHE_HOME = "/toolbox/wd15/.cache";
  };

  home.file = {
    ".bashrc".enable = false;
    ".bash_profile".enable = false;
    ".profile".enable = false;

    ".bashrc-hm".source = config.home.file.".bashrc".source;
    ".bash_profile-hm".source = config.home.file.".bash_profile".source;
    ".profile-hm".source = config.home.file.".profile".source;
  };

  home.activation.pinBootstrapBash = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    BASH_PATH=$(readlink -f "$HOME/.nix-profile/bin/bash")
    if [ -n "$BASH_PATH" ] && [ -e "$BASH_PATH" ]; then
      mkdir -p "$HOME/.gcroots"
      /toolbox/wd15/opt/bin/nix-store --add-root "$HOME/.gcroots/bash-pinned" --indirect -r "$(dirname "$(dirname "$BASH_PATH")")" 2>&1 || true
      echo "$(dirname "$(dirname "$BASH_PATH")")" > "$HOME/.bootstrap-bash-path"
      $VERBOSE_ECHO "Pinned bootstrap bash to: $BASH_PATH"
    else
      echo "WARNING: could not resolve ~/.nix-profile/bin/bash -- bootstrap pin not updated" >&2
    fi
  '';
}

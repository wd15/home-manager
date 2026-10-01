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

  home.activation.pinBootstrapBash = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Use Nix string interpolation to get the exact store path at build time.
    # This guarantees the path is correct and completely bypasses readlink.
    BASH_STORE_PATH="${pkgs.bashInteractive}"

    mkdir -p "$HOME/.gcroots"
    /toolbox/wd15/opt/bin/nix-store --add-root "$HOME/.gcroots/bash-pinned" --indirect -r "$BASH_STORE_PATH" 2>&1 || true

    echo "$BASH_STORE_PATH" > "$HOME/.bootstrap-bash-path"
    $VERBOSE_ECHO "Pinned bootstrap bash to: $BASH_STORE_PATH"
  '';
}

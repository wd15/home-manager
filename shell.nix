pkgs:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    HOSTNAME=$(uname -n)
    rsync --delete -azvv -e ssh --exclude Downloads --exclude .cache /home/wd15/ wd15@h190143:/vol0/laptops/wd15/$HOSTNAME
  '';
  vpn = pkgs.writeShellScriptBin "vpn" ''
    xdg-settings set default-web-browser google-chrome.desktop
    /opt/cisco/secureclient/bin/vpnui
    xdg-settings set default-web-browser vivaldi-stable.desktop
  '';
  mouse = pkgs.writeShellScriptBin "mouse" ''
    sudo systemctl start bluetooth.service
  '';
  jupyter-cricket = pkgs.writeShellScriptBin "jupyter-cricket" ''
    ssh -t -L 8889:127.0.0.1:8889 cricket '~/.cargo/bin/nix-user-chroot /usr/local/wd15/nix bash -l jupyter-remote'
  '';
  bat = pkgs.writeShellScriptBin "bat" ''
    upower -d | grep time
  '';
  conda-activate =  pkgs.writeShellScriptBin "conda-activate" ''
    eval "$(/home/wd15/miniforge3/bin/conda shell.bash hook)"
  '';
in
  [
    backup
    vpn
    mouse
    jupyter-cricket
    bat
    conda-activate
  ]

pkgs:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    HOSTNAME=$(uname -n)
    rsync --delete -azvv -e ssh /home/wd15/ wd15@h190143:/vol0/laptops/wd15/$HOSTNAME
  '';
  vpn = pkgs.writeShellScriptBin "vpn" ''
    xdg-settings set default-web-browser google-chrome.desktop
    /opt/cisco/anyconnect/bin/vpnui
    xdg-settings set default-web-browser firefox.desktop
  '';
in
  [
    backup
    vpn
  ]

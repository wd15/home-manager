pkgs:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    rsync --delete -azvv -e ssh /home/wd15/ wd15@h190143:/vol0/laptops/wd15/
  '';
  vpn = pkgs.writeShellScriptBin "vpn" ''
    xdg-settings set default-web-browser google-chrome.desktop
    /opt/cisco/anyconnect/bin/vpnui
    xdg-settings set default-web-browser my-browser.desktop
  '';
in
  [
    backup
    vpn
  ]

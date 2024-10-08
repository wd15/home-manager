pkgs:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    HOSTNAME=$(uname -n)
    rsync --delete -azvv -e ssh --exclude Downloads /home/wd15/ wd15@h190143:/vol0/laptops/wd15/$HOSTNAME
  '';
  vpn = pkgs.writeShellScriptBin "vpn" ''
    xdg-settings set default-web-browser google-chrome.desktop
    /opt/cisco/secureclient/bin/vpnui
    xdg-settings set default-web-browser vivaldi-stable.desktop
  '';
  mouse = pkgs.writeShellScriptBin "mouse" ''
    sudo systemctl start bluetooth.service
  '';
  
in
  [
    backup
    vpn
    mouse
  ]

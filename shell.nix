pkgs:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    #!/bin/bash
    rsync --delete -azvv -e ssh /home/wd15/ wd15@h190143:/vol0/laptops/wd15/
  '';
  vpn = pkgs.writeShellScriptBin "vpn" ''
    #!/bin/bash
    xdg-settings set default-web-browser chrome-browser-stable.desktop
    /opt/cisco/anyconnect/bin/vpnui
    xdg-settings set default-web-browser firefox.desktop
  '';
in
  [
    backup
    vpn
  ]

# ============================================================
# browsers.nix
# Wrapped browser packages + all XDG/MIME/desktop-entry wiring
# that exists solely to route file types to them. Kept together
# since none of these pieces make sense without the others.
# ============================================================
{ config, pkgs, ... }:

let
  vivaldi-fixed = pkgs.symlinkJoin {
    name = "vivaldi-fixed";
    paths = [ (pkgs.vivaldi.override { proprietaryCodecs = true; enableWidevine = true; }) ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/vivaldi \
        --run 'unset DBUS_SESSION_BUS_ADDRESS'

      if [ -e $out/bin/vivaldi-stable ]; then
        wrapProgram $out/bin/vivaldi-stable \
          --run 'unset DBUS_SESSION_BUS_ADDRESS'
      fi

      # Strip out the original desktop files entirely so they never collide with Home Manager
      rm -rf $out/share/applications
    '';
  };

  google-chrome-fixed = pkgs.symlinkJoin {
    name = "google-chrome-fixed";
    paths = [ pkgs.google-chrome ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/google-chrome-stable --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

  obsidian-fixed = pkgs.symlinkJoin {
    name = "obsidian-fixed";
    paths = [ pkgs.obsidian ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/obsidian --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

  code-cursor-fixed = pkgs.symlinkJoin {
    name = "code-cursor-fixed";
    paths = [ pkgs.code-cursor ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cursor --run 'unset DBUS_SESSION_BUS_ADDRESS'
      rm -rf $out/share/applications
    '';
  };

in
{
  home.packages = [
    vivaldi-fixed
    google-chrome-fixed
    obsidian-fixed
    code-cursor-fixed
  ];

  xdg.mime.enable = true;
  xdg.configFile."mimeapps.list".force = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "vivaldi-stable.desktop";
      "x-scheme-handler/http" = "vivaldi-stable.desktop";
      "x-scheme-handler/https" = "vivaldi-stable.desktop";
      "x-scheme-handler/about" = "vivaldi-stable.desktop";
      "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      "application/xhtml+xml" = "vivaldi-stable.desktop";
    };
  };

  xdg.desktopEntries = {
    vivaldi-stable = {
      name = "Vivaldi";
      genericName = "Web Browser";
      exec = "${vivaldi-fixed}/bin/vivaldi %U";
      icon = "vivaldi";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
      mimeType = [ "text/html" "x-scheme-handler/http" "x-scheme-handler/https" ];
    };

    google-chrome = {
      name = "Google Chrome";
      genericName = "Web Browser";
      exec = "${google-chrome-fixed}/bin/google-chrome-stable %U";
      icon = "google-chrome";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };

    obsidian = {
      name = "Obsidian";
      genericName = "Knowledge Base";
      exec = "${obsidian-fixed}/bin/obsidian %U";
      icon = "obsidian";
      terminal = false;
      categories = [ "Office" ];
    };

    cursor = {
      name = "Cursor";
      genericName = "Text Editor";
      exec = "${code-cursor-fixed}/bin/cursor %U";
      icon = "cursor";
      terminal = false;
      categories = [ "Development" "TextEditor" ];
    };
  };

  home.extraProfileCommands = ''
    if [[ -d "$out/share/applications" ]] ; then
      ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
    fi
  '';

  programs.firefox.enable = true;
}

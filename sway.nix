{ config, pkgs, ... }:

{
  # Wayland-Specific Packages
  home.packages = with pkgs; [
    wl-clipboard     # Replaces xclip/xsel for copy/paste
    wdisplays        # Replaces xrandr for monitor configuration
    swaybg           # For setting wallpaper
    swayidle         # For idle management
    swaylock         # For screen locking
    alacritty        # Hardware-accelerated Wayland terminal
  ];

  # =========================================================
  # WAYLAND DESKTOP ENVIRONMENT (SWAY)
  # =========================================================

  wayland.windowManager.sway = {
    enable = true;

    # Required for standalone Home Manager on Ubuntu
    wrapperFeatures.gtk = true;

    config = rec {
      modifier = "Mod4"; # Maps to Super/Windows key, just like Regolith

      # Use Wofi for the app launcher (Regolith/Rofi equivalent)
      menu = "${pkgs.wofi}/bin/wofi --show drun --allow-images";

      # We define a dedicated terminal.
      terminal = "${pkgs.alacritty}/bin/alacritty";

      # Disable the default Sway bar in favor of Waybar
      bars = [];

      # Inherit default Sway bindings, but override specific ones to match Regolith
      # Inherit default Sway bindings, but override specific ones to match Regolith
      keybindings = pkgs.lib.mkOptionDefault {
        "${modifier}+Space" = "exec ${menu}";
        "${modifier}+Return" = "exec ${terminal}"; # <-- Changed from Enter to Return
        "${modifier}+Shift+q" = "kill";
        "${modifier}+Shift+e" = "exec swaynag -t warning -m 'Exit Sway?' -B 'Yes' 'swaymsg exit'";
      };
    };

    # Export variables so GTK/Firefox know they are running under Wayland
    extraSessionCommands = ''
      export XDG_SESSION_TYPE=wayland
      export XDG_CURRENT_DESKTOP=sway
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM=wayland
    '';
  };

  # App Launcher
  programs.wofi = {
    enable = true;
  };

  # Status Bar
  programs.waybar = {
    enable = true;
    systemd.enable = true; # Let Home Manager start it automatically with Sway
  };

  # Notification Daemon
  services.mako = {
    enable = true;
    settings = {
      defaultTimeout = 5000;
    };
  };
}

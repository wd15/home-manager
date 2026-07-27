{ config, pkgs, ... }:

{
  # Install our essential desktop tools
  home.packages = with pkgs; [
    kitty      # Fast, GPU-accelerated terminal
    wofi       # App launcher
    pkgs.brightnessctl
    pkgs.mako
  ];

  # --- SCREEN LOCKER ---
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };

      background = [
        {
          path = "/home/wd15/.config/wallpaper.jpg"; # Reuses your wallpaper!
          blur_passes = 0;                           # Blurs it nicely
          blur_size = 0;
        }
      ];

      input-field = [
        {
          size = "250, 50";
          position = "0, -20";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          outline_thickness = 2;
          placeholder_text = "<i>Input Password...</i>";
        }
      ];
    };
  };

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        # Choose which modules go where
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "pulseaudio" "battery" "clock" "tray" ];

        # Configure the clock format
        clock = {
          format = "{:%I:%M %p  %A, %b %d}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };
      };
    };
  };

  # --- APP LAUNCHER ---
  programs.wofi.enable = true;

  xdg.configFile."mako/config".text = ''
    default-timeout=5000
    max-visible=5
    sort=-time
  '';

  ##### # --- NOTIFICATIONS ---
  ##### services.mako = {
  #####   enable = true;
  #####   settings = {
  #####     default-timeout = 5000;
  #####     max-visible = 5;
  #####     sort="-time";
  #####   };
  ##### };

  # --- WALLPAPER ENGINE ---
  services.hyprpaper = {
    enable = true;
    settings = {
      # We will set a temporary dummy path. You will change this to a real image later!
      preload = [ "~/.config/wallpaper.jpg" ];
      wallpaper = [ ",~/.config/wallpaper.jpg" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;


    settings = {
      # Permanent Monitor Layout
      # Syntax: "name, resolution@refresh, position, scale"
      monitor = [
        "DP-1, 2560x1440@60, 4480x0, 1"   # left
        "eDP-1, 1920x1080@144, 0x0, 1"    # center
        "HDMI-A-1, 2560x1440@60, 1920x0, 1"   # right
      ];

      exec-once = [
        "waybar"
        "mako"
        "hyprpaper"
      ];
      # 1. Set your modifier key to the Windows/Super key
      "$mod" = "SUPER";

      # --- HARDWARE CONTROLS (Volume & Brightness) ---
      bindel = [
        # Audio (PulseAudio standard)
        ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
        ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"

        # Brightness
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];

      # 2. Configure basic keybindings
      bind = [
        # --- BASIC ESSENTIALS ---
        "$mod, Return, exec, kitty"
        "$mod, D, exec, wofi --show drun"
        "$mod, Q, killactive,"
        "$mod SHIFT, E, exit,"

        # --- OPTION 1: BULLETPROOF VIM KEYS (Highly Recommended) ---
        # Super + H/J/K/L to move focus
        "$mod, H, movefocus, l"
        "$mod, L, movefocus, r"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        # Super + Shift + H/J/K/L to move windows
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, J, movewindow, d"

        # --- OPTION 2: CAPITALIZED ARROW KEYS ---
        # Super + Arrows to move focus
        "$mod, Left, movefocus, l"
        "$mod, Right, movefocus, r"
        "$mod, Up, movefocus, u"
        "$mod, Down, movefocus, d"

        # Super + Shift + Arrows to move windows
        "$mod SHIFT, Left, movewindow, l"
        "$mod SHIFT, Right, movewindow, r"
        "$mod SHIFT, Up, movewindow, u"
        "$mod SHIFT, Down, movewindow, d"

        # --- WORKSPACE NAVIGATION ---
        # Switch to workspace 1-9
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move active window to workspace 1-9
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # lockscreen
        "$mod, escape, exec, /usr/local/bin/hyprlock"

      ];


      # 3. Mandatory Nvidia Environment Variables
      env = [
        "LIBVA_DRIVER_NAME,nvidia"
        "XDG_SESSION_TYPE,wayland"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
      ];

      # 4. Fix the invisible Nvidia cursor bug
      cursor = {
        no_hardware_cursors = true;
      };
    };
  };
}

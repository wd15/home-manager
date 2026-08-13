{ config, pkgs, ... }:

{
  imports = [
    ./waybar.nix
  ];

  # Install our essential desktop tools
  home.packages = with pkgs; [
    kitty      # Fast, GPU-accelerated terminal
    wofi       # App launcher
    pkgs.brightnessctl
    pkgs.nwg-displays
    pavucontrol
    networkmanagerapplet
    blueman
    hyprland-autoname-workspaces   # <- new
    font-awesome
    xdg-utils         # Lets apps open web links
    polkit_gnome      # The password prompt GUI
  ];

  systemd.user.services.hyprland-autoname-workspaces = {
    Unit = {
      Description = "Rename Hyprland workspaces after running apps";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprland-autoname-workspaces}/bin/hyprland-autoname-workspaces";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

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

  # --- APP LAUNCHER ---
  programs.wofi.enable = true;

  xdg.configFile."mako/config".text = ''
    default-timeout=5000
    max-visible=5
    sort=-time
  '';

  # --- NOTIFICATIONS ---
  services.mako = {
    enable = true;
    settings = {
      "default-timeout" = 5000;
      "max-visible" = 5;
      sort = "-time";
      # If there is an action, do it. Otherwise, dismiss!
      "on-button-left" = "invoke-default-action,dismiss";
    };
  };

  # --- WALLPAPER ENGINE ---
  services.hyprpaper = {
    enable = true;
    settings = {
      # We will set a temporary dummy path. You will change this to a real image later!
      preload = [ "/home/wd15/.config/wallpaper.jpg" ];
      wallpaper = [ ",/home/wd15/.config/wallpaper.jpg" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # Permanent Monitor Layout
      # Syntax: "name, resolution@refresh, position, scale"

      # Permanent Monitor Layout
      # Syntax: "desc:HardwareName, resolution@refresh, position, scale"
      monitor = [
        # --- WORK SETUP ---
        # Left (DP-1) - Locked to 60Hz for stability
        "desc:ASUSTek COMPUTER INC ASUS VG32VQ1B 0x0000F8B4, 2560x1440@60, 0x0, 1"

        # Center (eDP-1) - Laptop screen
        "desc:BOE 0x0A15, 1920x1080@144, 2560x0, 1"

        # Right (HDMI-A-1)
        "desc:ASUSTek COMPUTER INC VG32VQ1B RCLMTF029491, 2560x1440@60, 4480x0, 1"

        # --- HOME SETUP ---
        # Left (DP-1) - Samsung 32"
        "desc:Samsung Electric Company C32H71x HTPJ500129, 2560x1440@60, 4480x0, 1"

        # Right (HDMI-A-1) - ASUS 32"
        # (Explicitly forcing 1440p@60Hz to override the 1080p HDMI EDID bug)
        "desc:ASUSTek COMPUTER INC ASUS VG32VQ1B 0x0004F2A8, 2560x1440@60, 0x0, 1"

        # --- TRAVEL SAFETY NET ---
        # Catch-all for projectors. Locked to 1080p @ 60Hz so it NEVER chokes!
        ", preferred, auto, 1"
      ];

      exec-once = [
        "mako"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "nm-applet --indicator"
        "blueman-applet"
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

        # Super + Shift + W: Reload Waybar and Hyprpaper across all monitors
        "$mod SHIFT, W, exec, systemctl --user restart waybar && systemctl --user restart hyprpaper"

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
        "$mod, grave, workspace, empty"

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

        # Move active to next emtpy
        "$mod SHIFT, grave, movetoworkspace, empty"

        # lockscreen
        "$mod, escape, exec, /usr/local/bin/hyprlock"

        # --- PROJECTOR CONTROLS ---
        # Super + P: Mirror laptop to projector safely
        "$mod, P, exec, hyprctl keyword monitor \", 1920x1080@60, auto, 1, mirror, eDP-1\""

        # Super + Shift + P: Revert to extended side-by-side mode safely
        "$mod SHIFT, P, exec, hyprctl keyword monitor \", 1920x1080@60, auto, 1\""

        # --- SCREENSHOTS ---
        # Super + Shift + S: Select area to copy and save
        "$mod SHIFT, S, exec, grimblast copysave area"

        # Print Screen key: Select area to copy and save
        ", Print, exec, grimblast copysave area"
      ];


      # 3. Mandatory Nvidia Environment Variables
      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
        "LIBVA_DRIVER_NAME,nvidia"
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

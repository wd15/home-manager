{ config, pkgs, ... }:

{
  wayland.windowManager.hyprland.settings = {
    # --- MODIFIER KEY ---
    "$mod" = "SUPER";

    # --- HARDWARE CONTROLS (Volume & Brightness) ---
    bindel = [
      ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
      ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
      ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ];

    # --- KEYBINDINGS ---
    bind = [
      # Basic Essentials
      "$mod, Return, exec, kitty"
      "$mod, D, exec, wofi --show drun"
      "$mod, Q, killactive,"
      "$mod SHIFT, E, exit,"

      # Reload Waybar & Hyprpaper safely
      "$mod SHIFT, W, exec, pkill -f waybar; systemctl --user restart waybar && systemctl --user restart hyprpaper"

      # Focus Movement (Vim Keys)
      "$mod, H, movefocus, l"
      "$mod, L, movefocus, r"
      "$mod, K, movefocus, u"
      "$mod, J, movefocus, d"

      # Window Movement (Vim Keys)
      "$mod SHIFT, H, movewindow, l"
      "$mod SHIFT, L, movewindow, r"
      "$mod SHIFT, K, movewindow, u"
      "$mod SHIFT, J, movewindow, d"

      # Focus Movement (Arrow Keys)
      "$mod, Left, movefocus, l"
      "$mod, Right, movefocus, r"
      "$mod, Up, movefocus, u"
      "$mod, Down, movefocus, d"

      # Window Movement (Arrow Keys)
      "$mod SHIFT, Left, movewindow, l"
      "$mod SHIFT, Right, movewindow, r"
      "$mod SHIFT, Up, movewindow, u"
      "$mod SHIFT, Down, movewindow, d"

      # Workspace Navigation (1-9 & empty)
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

      # Move Active Window to Workspace
      "$mod SHIFT, 1, movetoworkspace, 1"
      "$mod SHIFT, 2, movetoworkspace, 2"
      "$mod SHIFT, 3, movetoworkspace, 3"
      "$mod SHIFT, 4, movetoworkspace, 4"
      "$mod SHIFT, 5, movetoworkspace, 5"
      "$mod SHIFT, 6, movetoworkspace, 6"
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, grave, movetoworkspace, empty"

      # Lock Screen
      "$mod, escape, exec, /usr/local/bin/hyprlock"

      # Projector Controls
      "$mod, P, exec, hyprctl keyword monitor \", 1920x1080@60, auto, 1, mirror, eDP-1\""
      "$mod SHIFT, P, exec, hyprctl keyword monitor \", 1920x1080@60, auto, 1\""

      # Screenshots
      "$mod SHIFT, S, exec, grimblast copysave area"
      ", Print, exec, grimblast copysave area"
    ];
  };
}

{ config, pkgs, ... }:

{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # Point directly to your custom Ubuntu-native binary
        lock_cmd = "pidof hyprlock || /usr/local/bin/hyprlock";
        before_sleep_cmd = "loginctl lock-session";    # Lock before the laptop suspends
        after_sleep_cmd = "hyprctl dispatch dpms on";  # Wake screens after suspend
      };

      listener = [
        # --- Screen Off (5 Minutes) ---
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";     # Turn off all screens
          on-resume = "hyprctl dispatch dpms on";       # Wake up screens when mouse moves
        }

        # --- Lock Session (10 Minutes) ---
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";         # Fire the custom lock_cmd
        }
      ];
    };
  };
}

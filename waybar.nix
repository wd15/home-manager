{ config, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        # This creates the "floating" effect (Top, Right, Bottom, Left)
        margin = "10 20 0 20";
        height = 36;
        spacing = 8;

        # Keep your exact module layout
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "network" "pulseaudio" "battery" "tray" ];


        # --- HYPRLAND SPECIFIC MODULES ---
        "hyprland/workspaces" = {
          # {name} pulls in the numbers AND the text from hyprland-autoname-workspaces!
          format = "{name}";
          # We removed the persistent dots so it only shows workspaces you are actually using
        };


        # # --- HYPRLAND SPECIFIC MODULES ---
        # "hyprland/workspaces" = {
        #   format = "{icon}";
        #   format-icons = {
        #     active = "";
        #     default = "";
        #     urgent = "";
        #   };
        #   persistent-workspaces = {
        #     "*" = 5; # Always show 5 dots
        #   };
        # };

        "hyprland/window" = {
          max-length = 50;
        };

        # --- STANDARD MODULES ---
        clock = {
          format = "  {:%I:%M %p}";
          format-alt = "  {:%A, %B %d, %Y}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        pulseaudio = {
          format = "{icon}  {volume}%";
          format-muted = "  Muted";
          format-icons = {
            default = ["" "" ""];
          };
          # Kept your exact click bindings!
          on-click = "pavucontrol";
          on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          scroll-step = 5;
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "  {ifname}";
          format-disconnected = "  Offline";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          # Kept your kitty/nmtui binding!
          on-click = "kitty -e nmtui";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon}  {capacity}%";
          format-charging = "  {capacity}%";
          format-plugged = "  {capacity}%";
          format-icons = ["" "" "" "" ""];
        };
      };
    };

    style = ''
      * {
        font-family: "Font Awesome 6 Free", "Font Awesome 6 Brands", sans-serif;
        font-size: 14px;
        font-weight: bold;
      }

      /* The main floating bar */
      window#waybar {
        background-color: rgba(30, 30, 46, 0.85); /* Semi-transparent Catppuccin Base */
        border: 2px solid rgba(137, 180, 250, 0.3); /* Subtle blue border */
        border-radius: 16px;
        color: #cdd6f4;
      }

      /* Clean up the modules */
      #workspaces,
      #window,
      #clock,
      #network,
      #pulseaudio,
      #battery,
      #tray {
        background-color: transparent;
        padding: 0 12px;
        margin: 4px 0;
      }

      /* Workspace Dots Styling */
      #workspaces button {
        padding: 0 10px;
        color: #585b70; /* Dimmed unactive dots */
        transition: all 0.3s ease;
      }

      #workspaces button.active {
        color: #89b4fa; /* Bright blue active dot */
      }

      #workspaces button:hover {
        color: #f5c2e7; /* Pink hover effect */
        box-shadow: none;
        text-shadow: none;
        background: transparent;
      }

      /* Color-code the right side modules via text, not background */
      #network { color: #f5e0dc; }
      #pulseaudio { color: #f9e2af; }
      #battery { color: #a6e3a1; }
      #battery.warning { color: #fab387; }
      #battery.critical { color: #f38ba8; animation: blink 1s steps(2, start) infinite; }

      #clock {
        color: #cba6f7;
      }

      /* Subtle blink animation for low battery */
      @keyframes blink {
        to {
          color: #1e1e2e;
        }
      }
    '';
  };
}

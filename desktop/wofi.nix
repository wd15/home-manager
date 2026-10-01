{ config, pkgs, ... }:

{
  programs.wofi = {
    enable = true;

    settings = {
      show = "drun";
      width = 600;
      height = 350;
      always_parse_args = true;
      show_all = true;
      print_command = true;
      insensitive = true;
      prompt = "Search Apps...";
      allow_images = true;     # Shows app icons!
      image_size = 24;
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;
        font-size: 16px;
      }

      /* The main window */
      window {
        margin: 0px;
        border: 2px solid rgba(137, 180, 250, 0.3); /* Matches Waybar border */
        background-color: rgba(30, 30, 46, 0.95);   /* Catppuccin base */
        border-radius: 16px;
      }

      /* The main background inside */
      #inner-box {
        margin: 10px;
        background-color: transparent;
      }

      /* The search bar */
      #input {
        margin-bottom: 15px;
        padding: 10px;
        color: #cdd6f4;
        background-color: #313244; /* Slightly lighter gray */
        border: none;
        border-radius: 12px;
      }

      #input:focus {
        border: 1px solid #89b4fa; /* Blue highlight when typing */
        box-shadow: none;
      }

      /* The list of apps */
      #scroll {
        margin-top: 5px;
        border: none;
      }

      /* Individual app entries */
      #entry {
        padding: 8px;
        border-radius: 12px;
      }

      #text {
        margin-left: 10px;
        color: #cdd6f4;
      }

      /* How it looks when you use arrow keys to select an app */
      #entry:selected {
        background-color: #45475a;
      }

      #entry:selected #text {
        color: #89b4fa;
        font-weight: bold;
      }
    '';
  };
}

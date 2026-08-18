{ config, pkgs, ... }:

{
  imports = [
    ./waybar.nix
    ./wofi.nix
    ./gtk.nix
    ./keybindings.nix
  ];

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    kitty
    brightnessctl
    nwg-displays
    pavucontrol
    networkmanagerapplet
    blueman
    font-awesome
    xdg-utils
    polkit_gnome
    nerd-fonts.jetbrains-mono
    xdg-desktop-portal-gtk
  ];

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          path = "/home/wd15/.config/wallpaper.jpg";
          blur_passes = 0;
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
          placeholder_text = "Input Password...";
        }
      ];
    };
  };

  services.mako = {
    enable = true;
    settings = {
      "default-timeout" = 5000;
      "max-visible" = 5;
      sort = "-time";
      "on-button-left" = "invoke-default-action,dismiss";
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "/home/wd15/.config/wallpaper.jpg" ];
      wallpaper = [ ",/home/wd15/.config/wallpaper.jpg" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      monitor = [
        "desc:ASUSTek COMPUTER INC ASUS VG32VQ1B 0x0000F8B4, 2560x1440@60, 0x0, 1"
        "desc:BOE 0x0A15, 1920x1080@144, 2560x0, 1"
        "desc:ASUSTek COMPUTER INC VG32VQ1B RCLMTF029491, 2560x1440@60, 4480x0, 1"
        "desc:Samsung Electric Company C32H71x HTPJ500129, 2560x1440@60, 4480x0, 1"
        "desc:ASUSTek COMPUTER INC ASUS VG32VQ1B 0x0004F2A8, 2560x1440@60, 0x0, 1"
        ", preferred, auto, 1"
      ];

      exec-once = [
        "mako"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "nm-applet --indicator"
        "blueman-applet"
      ];

      env = [
        "XDG_CURRENT_DESKTOP,Hyprland"
         "XDG_SESSION_TYPE,wayland"
        "XDG_SESSION_DESKTOP,Hyprland"
        "LIBVA_DRIVER_NAME,nvidia"
        "GBM_BACKEND,nvidia-drm"
        "__GLX_VENDOR_LIBRARY_NAME,nvidia"
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,24"
        "GTK_THEME,adw-gtk3-dark"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      windowrulev2 = [
        # Force Vivaldi's internal file chooser window to float!
        "float, class:^(\\.vivaldi-wrapped)$, title:^(Open Files)$"
        "center, class:^(\\.vivaldi-wrapped)$, title:^(Open Files)$"
        "size 900 600, class:^(\\.vivaldi-wrapped)$, title:^(Open Files)$"

        # General file chooser fallbacks (for other browser/app popups)
        "float, title:^(Open File)$"
        "float, title:^(Select a File)$"
        "float, title:^(Choose Files)$"
        "float, title:^(Save As)$"
        "float, class:^(xdg-desktop-portal-.*)$"
        "center, class:^(xdg-desktop-portal-.*)$"
        "size 900 600, class:^(xdg-desktop-portal-.*)$"
      ];

    };
  };
}

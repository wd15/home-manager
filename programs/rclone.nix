{ pkgs, ... }:

{
  home.packages = [ pkgs.rclone ];

  systemd.user.services.rclone-pdfs-bisync = {
    Unit = {
      Description = "Two-way sync ~/org/roam/pdfs with Proton Drive";
      After = [ "network-online.target" ];
      OnFailure = [ "notify-failure@%n.service" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.rclone}/bin/rclone bisync %h/org/roam/pdfs proton:org-roam-pdfs \
          --create-empty-src-dirs \
          --conflict-resolve newer \
          --resilient \
          --recover \
          --max-lock 2m \
          --log-level INFO
      '';
    };
  };

  systemd.user.services."notify-failure@" = {
    Unit = {
      Description = "Send desktop notification when %i fails";
    };
    Service = {
      Type = "oneshot";
      ExecStart = ''
        ${pkgs.libnotify}/bin/notify-send \
          --urgency=critical \
          --app-name="systemd" \
          "Service Failed: %i" \
          "Check logs: journalctl --user -u %i -n 20"
      '';
    };
  };

  systemd.user.timers.rclone-pdfs-bisync = {
    Unit = {
      Description = "Run Proton Drive PDF bisync every 15 minutes";
    };
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "15m";
      Persistent = true;
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}

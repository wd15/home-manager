# ============================================================
# zsh.nix  (merged -- replaces both bash.nix and bash-cluster.nix)
# Takes isCluster from specialArgs to branch on the few things
# that genuinely differ. Everything else is shared.
# ============================================================
{ pkgs, isCluster ? false, ... }:
{

  programs.bash = {
    enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      scan_timeout = 5000;

      format = "$hostname$shlvl\${custom.nix}$directory$git_branch$git_status\${custom.jj}$package$julia$python$cmd_duration\n$character";

      custom.jj = {
        command = "jj log -r @ --no-graph -T 'change_id.short() ++ \" (\" ++ commit_id.short() ++ \")\"'";
        when = "jj root";
        symbol = "🥋 ";
        style = "bold purple";
        format = "on [$symbol$output]($style) ";
      };

      git_branch = {
        only_attached = true;
      };

      shlvl = {
        disabled = false;
        threshold = 3;
        symbol = "⚡";
        repeat = false;
        format = "[$symbol]($style) ";
      };

      nix_shell = { disabled = true; };

      custom.nix = {
        when = "test -n \"$IN_NIX_SHELL\"";
        command = "echo '(nix)'";
        format = "[($output)]($style) ";
        style = "bold blue";
      };

      hostname = {
        ssh_only = false;
        format = "[\\[$hostname\\]]($style) ";
        style = "bold green";
      };

      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
        style = "bold yellow";
      };

      os = { disabled = true; };
      gcloud = { disabled = true; };
      aws = { disabled = true; };
      openstack = { disabled = true; };
    };
  };

  # --- ZSH CONFIGURATION ---
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    completionInit = "autoload -U compinit && compinit -i";

    # Give Zsh the "Fish" superpowers
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Inject Nix environment variables so Hyprland inherits the PATH
    # envExtra = ''
    #   if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    #     . "$HOME/.nix-profile/etc/profile.d/nix.sh"
    #   fi
    #   if [ -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    #     . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    #   fi
    # '';

    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -l";
      la = "ls -A";
      dir = "ls --color=auto --format=vertical";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";
      mkdir = "mkdir -p";
      edit = "emacs -nw";
      j = "jj";
      jst = "jj status";
      jlog = "jj log";
      jdiff = "jj diff";
      jnew = "jj new";
      jpush = "jj git push";
      jfetch = "jj git fetch";
      jdone = "jj done";
      work = "cd -P ~/work";
    }
    # ---- Laptop-only aliases ----
    // (if !isCluster then {
      lock = "hyprlock";
      firedef = "xdg-settings set default-web-browser firefox.desktop";
      vivdef = "xdg-settings set default-web-browser vivaldi-stable.desktop";
      bstart = "sudo systemctl start bluetooth.service";
      thermocalc = "/opt/Thermo-Calc/2024b/Thermo-Calc.sh";
      cricket = "ssh cricket '~/ni'";
      pbcopy = "wl-copy";
      mirror = "hyprctl keyword monitor \", preferred, auto, 1, mirror, eDP-1\"";
      extend = "hyprctl keyword monitor \", preferred, auto, 1\"";
    } else {})
    # ---- Cluster-only aliases ----
    // (if isCluster then {
      sjobs = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R" -u ''${USER}'';
      sjobsall = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R"'';
      cancel = "scancel";
    } else {});

    initExtra = ''
      # Enable interactive dropdown menus for Tab completion
      zstyle ':completion:*' menu select

      ${if isCluster then ''
        # ---- Preserve HPC module-system compatibility (cluster only) ----
        if [ -z "$loginsh" ]; then
          if [ -n "''${ZSH_VERSION}" ]; then
            for i in /etc/profile.d/*.sh; do
              if [ -r "$i" ]; then
                . "$i"
              fi
            done
          fi
        fi
        unset loginsh

        # ---- Self-Healing Fast Path Pin ----
        if [ -n "$IN_NIX_NAMESPACE" ]; then
          ACTIVE_ZSH_BIN=$(readlink /proc/$$/exe)
          echo "''${ACTIVE_ZSH_BIN%/bin/zsh}" > ~/.bootstrap-zsh-path
          export SHELL="$HOME/.nix-profile/bin/zsh"
        fi

      '' else ""}

      # ---- tmux auto-attach (shared) ----
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
          { tmux; [ ! -f ~/dontdie ] && exit || rm ~/dontdie; }
      fi

      eval `dircolors -b`
      export HISTTIMEFORMAT="%d/%m/%y %T "
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8

      ${if !isCluster then ''
        # ---- Laptop-only: CUDA, browser, thermocalc ----
        export PATH=/usr/local/cuda-11.2/bin:''${PATH}
        export LD_LIBRARY_PATH=/usr/local/cuda-11.2/lib64:''${LD_LIBRARY_PATH}
        export PATH="$HOME/.nix-profile/bin:/nix/var/nix/profiles/default/bin:/usr/local/bin:$HOME/bin:$PATH"
        export PATH="/usr/local/bin:~/bin/:$PATH"
        export BROWSER=vivaldi
        export TC24B_HOME=/opt/Thermo-Calc/2024b
        export LSHOST=sequoia.nist.gov

        use_conda() {
          source ~/miniforge3/etc/profile.d/conda.sh
          export PATH="/home/wd15/miniforge3/bin:$PATH"
        }
      '' else ''
        # ---- Cluster-only PATH ----
        export PATH="/toolbox/wd15/opt/bin:~/.nix-profile/bin:/usr/local/bin:~/bin/:$PATH"
      ''}

      [ -f /etc/ssl/certs/ca-certificates.crt ] && export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

      # ---- micromamba shell hook (shared) ----
      __mamba_setup="$("$MAMBA_EXE" shell hook --shell zsh --root-prefix "''${MAMBA_ROOT_PREFIX:-$HOME/micromamba}" 2> /dev/null)"

      setwork() {
        ln -sfn "$PWD" ~/work
        echo "✅ '~/work' shortcut now points to: $(pwd)"
      }
    '';
  };
}

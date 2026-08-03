
# ============================================================
# bash.nix  (merged -- replaces both bash.nix and bash-cluster.nix)
# Takes isCluster from specialArgs to branch on the few things
# that genuinely differ. Everything else is shared.
# ============================================================
{ pkgs, isCluster ? false, ... }:

{
  programs.bash = {
    enable = true;

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
    }
    # ---- Laptop-only aliases ----
    // (if !isCluster then {
      lock = "/usr/local/bin/hyprlock";
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
      jobs = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R" -u ''${USER}'';
      jobsall = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R"'';
      cancel = "scancel";
    } else {});

    initExtra = ''
      ${if isCluster then ''
        # ---- Preserve HPC module-system compatibility (cluster only) ----
        # Re-source /etc/profile.d/*.sh for non-login interactive shells --
        # very likely how `module` (Lmod/environment-modules) gets injected
        # into shells that aren't the very first login shell.
        if [ -z "$loginsh" ]; then
          if [ -n "''${BASH_VERSION}" ]; then
            for i in /etc/profile.d/*.sh; do
              if [ -r "$i" ]; then
                . "$i"
              fi
            done
          fi
        fi
        unset loginsh
      '' else ""}

      # ---- Prompt (shared) ----
      parse_git_branch() {
        git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
      }
      PS1="[\\u@\\h:\\w]\[\e[1;34m\]\$(parse_git_branch)\[\e[m\]\[\e[1;32m\]$\[\e[m\] "
      PS1="\[\e[1;32m\]''${PS1}\[\e[m\]"

      show_shell_level() {
        if [[ -v IN_NIX_SHELL ]]; then
          echo -e -n '(nix)'
        fi
        if [[ $SHLVL -gt 2 ]]; then
          for in in $( eval echo {3..$SHLVL} ); do
            echo -e -n '\xe2\x9a\xa1'
          done
        fi
      }
      export -f show_shell_level
      export PS1="\[\e[1;34m\]\$(show_shell_level)\[\e[m\]"$PS1

      # ---- tmux auto-attach (shared) ----
      # Known gotcha: a tmux SERVER only captures env vars at the moment
      # it first starts. A "fresh" terminal attaching to an old server
      # can get stale WAYLAND_DISPLAY / SSH_AUTH_SOCK / etc. If something
      # env-related seems stuck, try `tmux kill-server` then reopen.
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
        export PATH="/usr/local/bin:~/bin/:$PATH"
        export BROWSER=vivaldi
        export TC24B_HOME=/opt/Thermo-Calc/2024b
        export LSHOST=sequoia.nist.gov

        use_conda() {
          source ~/miniforge3/etc/profile.d/conda.sh
          export PATH="/home/wd15/miniforge3/bin:$PATH"
        }
      '' else ''
        # ---- Cluster-only PATH (no CUDA hardcoding -- let module system provide it) ----
        export PATH="/usr/local/bin:~/bin/:$PATH"
      ''}

      [ -f /etc/bash_completion ] && source /etc/bash_completion
      [ -f ~/.git-completion.bash ] && source ~/.git-completion.bash
      [ -f /etc/ssl/certs/ca-certificates.crt ] && export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

      # ---- micromamba shell hook (shared) ----
      __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "''${MAMBA_ROOT_PREFIX:-$HOME/micromamba}" 2> /dev/null)"
    '';
  };
}

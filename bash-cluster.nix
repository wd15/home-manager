# ============================================================
# bash-cluster.nix
# ============================================================
{ pkgs, ... }:

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

      # Slurm queue view, scoped to your own jobs, sane column widths.
      jobs = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R" -u ''${USER}'';
      # Wider queue-of-everyone view, handy for checking cluster load.
      jobsall = ''squeue -o "%14i %10j %4t %8q %8a %8g %10P %10Q %8D %11l %11L %R"'';
      # Quick job cancel by ID: `cancel 12345`
      cancel = "scancel";
    };

    initExtra = ''
      # ---- Preserve HPC module-system compatibility ----
      # Re-source /etc/profile.d/*.sh for non-login interactive shells,
      # mirroring the site's own bashrc-mr-french. Very likely how
      # `module` (Lmod/environment-modules) gets injected into shells
      # that aren't the very first login shell.
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

      # ---- Prompt (portable, same as laptop) ----
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

      # ---- tmux auto-attach ----
      # NOTE: this is the exact mechanism that caused the stale
      # WAYLAND_DISPLAY/SSH_AUTH_SOCK bug on the laptop -- a tmux
      # SERVER started once keeps serving its original environment to
      # every later "fresh" shell that attaches to it. On the cluster
      # this matters most for SSH_AUTH_SOCK (agent forwarding): if you
      # forward your agent on a fresh SSH connection but attach to an
      # old tmux server, it may hand you a dead socket path from a
      # previous session.
      if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
          { tmux; [ ! -f ~/dontdie ] && exit || rm ~/dontdie; }
      fi

      eval `dircolors -b`
      export HISTTIMEFORMAT="%d/%m/%y %T "
      export PATH="/usr/local/bin:~/bin/:$PATH"
      export LANG=en_US.UTF-8
      export LC_ALL=en_US.UTF-8

      [ -f /etc/bash_completion ] && source /etc/bash_completion
      [ -f ~/.git-completion.bash ] && source ~/.git-completion.bash
      [ -f /etc/ssl/certs/ca-certificates.crt ] && export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

      # micromamba shell hook
      __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "''${MAMBA_ROOT_PREFIX:-/toolbox/wd15/micromamba}" 2> /dev/null)"
      if [ $? -eq 0 ]; then
         eval "$__mamba_setup"
      else
        alias micromamba="$MAMBA_EXE"
      fi
      unset __mamba_setup
    '';
  };
}

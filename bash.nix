pkgs: {
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
     # make sure xscreesaver is installed and screensaver runs on startup
     lock = "xscreensaver-command --lock";
     firedef = "xdg-settings set default-web-browser firefox.desktop";
     vivdef = "xdg-settings set default-web-browser vivaldi-stable.desktop";
     bstart = "sudo systemctl start bluetooth.service";
     thermocalc = "/opt/Thermo-Calc/2024b/Thermo-Calc.sh";
     ni = "~/.cargo/bin/nix-user-chroot /usr/local/wd15/nix bash -l";
     ansys = "/usr/local/ansys_inc/v194/ansys/bin/ansys194";
  };
  initExtra = ''
    # Configure prompt

    parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    PS1="[\\u@\\h:\\w]\[\e[1;34m\]\$(parse_git_branch)\[\e[m\]\[\e[1;32m\]$\[\e[m\] "
    PS1="\[\e[1;32m\]''${PS1}\[\e[m\]"

    show_nix_env() {
    if [[ -n "$IN_NIX_SHELL" ]]; then
      echo "(nix)"
    fi
    }
    export -f show_nix_env
    export PS1="\[\e[1;34m\]\$(show_nix_env)\[\e[m\]"$PS1

    if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
    fi


    eval `dircolors -b`
    export HISTTIMEFORMAT="%d/%m/%y %T "
    export PATH=/usr/local/cuda-11.2/bin:''${PATH}
    export LD_LIBRARY_PATH=/usr/local/cuda-11.2/lib64:''${LD_LIBRARY_PATH}
    # export EDITOR=emacs
    export PATH="/usr/local/bin:~/bin/:$PATH"
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    export BROWSER=vivaldi
    export TC24B_HOME=/opt/Thermo-Calc/2024b
    export LSHOST=sequoia.nist.gov
    export CDPATH=.:/usr/local/wd15/am-dt-twin-modeling
    source /etc/bash_completion
    source ~/.git-completion.bash
   
  '';

}

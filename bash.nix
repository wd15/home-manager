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
     cricket = "ssh cricket '~/ni'";
  };
  initExtra = ''
    # Configure prompt

    parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
    }
    PS1="[\\u@\\h:\\w]\[\e[1;34m\]\$(parse_git_branch)\[\e[m\]\[\e[1;32m\]$\[\e[m\] "
    PS1="\[\e[1;32m\]''${PS1}\[\e[m\]"

    show_shell_level() {
      if [[ -v IN_NIX_SHELL ]]
      then
        echo -e -n '(nix)'
      fi
      if [[ $SHLVL -gt 2 ]]; then
        for in in $( eval echo {3..$SHLVL} );
        do
          echo -e -n '\xe2\x9a\xa1'
        done
      fi
    }
    export -f show_shell_level
    export PS1="\[\e[1;34m\]\$(show_shell_level)\[\e[m\]"$PS1

    if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
        { tmux; [ ! -f ~/dontdie ] && exit || rm ~/dontdie; }
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
    source /etc/bash_completion
    source ~/.git-completion.bash
    export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

    # >>> mamba initialize >>>
    # !! Contents within this block are managed by 'mamba init' !!
    export MAMBA_EXE='/nix/store/p5z4d0vcafi64l7l3crnjjml8mhx7z13-micromamba-1.5.4/bin/micromamba';
    export MAMBA_ROOT_PREFIX='/home/wd15/micromamba';
    __mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
    if [ $? -eq 0 ]; then
       eval "$__mamba_setup"
    else
      alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
    fi
    unset __mamba_setup
    # <<< mamba initialize <<<


    # # >>> conda initialize >>>
    # # !! Contents within this block are managed by 'conda init' !!
    # __conda_setup="$('/home/wd15/miniforge3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    # if [ $? -eq 0 ]; then
    #    eval "$__conda_setup"
    # else
    #     if [ -f "/home/wd15/miniforge3/etc/profile.d/conda.sh" ]; then
    #         . "/home/wd15/miniforge3/etc/profile.d/conda.sh"
    #     else
    #         export PATH="/home/wd15/miniforge3/bin:$PATH"
    #     fi
    # fi
    # unset __conda_setup
    # # <<< conda initialize <<<

    ## Switch on Conda
    use_conda() {
      source ~/miniforge3/etc/profile.d/conda.sh
      export PATH="/home/wd15/miniforge3/bin:$PATH"
    }
      
  '';

}

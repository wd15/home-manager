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
     vpn = "/opt/cisco/anyconnect/bin/vpnui";
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


    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/wd15/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
    eval "$__conda_setup"
    else
    if [ -f "/home/wd15/miniconda3/etc/profile.d/conda.sh" ]; then
    . "/home/wd15/miniconda3/etc/profile.d/conda.sh"
    else
    export PATH="/home/wd15/miniconda3/bin:$PATH"
    fi
    fi
    unset __conda_setup

    if [ -f "/home/wd15/miniconda3/etc/profile.d/mamba.sh" ]; then
    . "/home/wd15/miniconda3/etc/profile.d/mamba.sh"
    fi
    # <<< conda initialize <<<


    if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
    exec tmux
    fi


    eval `dircolors -b`
    export HISTTIMEFORMAT="%d/%m/%y %T "
    export PATH=/usr/local/cuda-11.2/bin:''${PATH}
    export LD_LIBRARY_PATH=/usr/local/cuda-11.2/lib64:''${LD_LIBRARY_PATH}
    export EDITOR=emacs
    export PATH="/usr/local/bin:~/bin/:$PATH"
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    source /etc/bash_completion
    source ~/.git-completion.bash
    source ~/git/nixpkgs-review-checks/bashrc

  '';

}

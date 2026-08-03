
# ============================================================
# home-cluster.nix  (full file -- corrected)
#
# FIXED: removed NIX_STATE_DIR / NIX_PROFILE / sessionPath entries
# that pointed at /toolbox/wd15/user_nix -- confirmed (2026-07-31)
# that this is a STALE, UNUSED directory from an earlier abandoned
# install attempt (timestamps: Mar 2025, vs. the real store's Aug
# 2025/Jul 2026 activity). The actual store in use is confirmed via
# nix.conf: store = /toolbox/wd15/opt. Overriding NIX_PROFILE to
# point at the wrong store is what caused ~/.nix-profile to end up
# dangling, contributing to the PATH/login breakage incident --
# see README incident notes.
#
# Now imports the MERGED bash.nix (bash-cluster.nix deleted) --
# same file as laptop, branches internally on isCluster.
# ============================================================
{ config, pkgs, lib, ... }:

{
  imports = [
    ./bash.nix                # merged laptop+cluster, branches on isCluster
    ./emacs.nix                # headless-safe as-is
    ./git-ssh.nix              # shared: git/ssh dotfiles + keychain + mambarc
    ./packages-cluster.nix
  ];

  home.username = "wd15";
  home.homeDirectory = "/users/wd15";   # confirmed via mr-french, NOT /home/wd15
  home.stateVersion = "24.05";

  targets.genericLinux.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs -nw";
    MAMBA_EXE = "${pkgs.micromamba}/bin/micromamba";

    # Keep Nix's cache off NFS-backed $HOME (confirmed: /users/wd15 is
    # genie:/vol0/home/wd15, network-mounted, 98% full) and onto local
    # block storage instead.
    XDG_CACHE_HOME = "/toolbox/wd15/.cache";

    # NIX_STATE_DIR / NIX_PROFILE deliberately NOT set here.
    # Home Manager manages ~/.nix-profile itself against whatever
    # store nix.conf points to (/toolbox/wd15/opt) -- don't override.
  };

  # sessionPath deliberately empty here -- /toolbox/wd15/opt/bin is
  # already reachable via the profile mechanism once ~/.nix-profile
  # is correctly linked; no hardcoded user_nix path needed.

  programs.home-manager.enable = true;

  programs.tmux = {
    enable = true;
    mouse = true;
    # No Wayland clipboard binding -- no compositor on a compute node.
  };

  # De-symlink .bashrc/.profile/.bash_profile and inject a namespace bootstrap.
  # If /nix doesn't exist, we immediately re-exec into the Nix namespace bubble.
  home.activation.desymlinkLoginFiles = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for f in "$HOME/.bashrc" "$HOME/.profile" "$HOME/.bash_profile"; do
      if [ -L "$f" ]; then
        real_target=$(readlink -f "$f")
        if [ -f "$real_target" ]; then
          tmp="$f.desymlink.tmp"

          # 1. Inject the namespace bootstrap code at the very top
          cat << 'EOF' > "$tmp"
# --- AUTO-NAMESPACE BOOTSTRAP ---
if [ ! -d "/nix" ]; then
  # We are outside the namespace bubble. Inject Nix into path and re-exec inside it.
  export PATH="/toolbox/wd15/opt/bin:$PATH"
  exec /toolbox/wd15/opt/bin/nix shell nixpkgs#bash -c 'exec bash -l'
fi
# --- END BOOTSTRAP ---
EOF

          # 2. Append the pristine, native Home Manager script
          cat "$real_target" >> "$tmp"

          mv -f "$tmp" "$f"
          $VERBOSE_ECHO "De-symlinked and injected namespace bootstrap into $f"
        else
          echo "WARNING: $f is a symlink but target '$real_target' doesn't exist or isn't readable -- leaving as-is" >&2
        fi
      fi
    done
  '';

}

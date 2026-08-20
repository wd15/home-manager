{ pkgs, ... }:
{
  # home.nix or modules/jujutsu.nix
  programs.jujutsu = {
    enable = true;

    settings = {
      user = {
        name = "Daniel Wheeler";
        email = "daniel.wheeler2@gmail.com";
      };

      # Custom JJ aliases
      aliases = {
        # Short navigation & log views
        l = ["log" "-r" "::@ | ::main"];                 # Compact log of current workspace + main
        la = ["log" "-r" "all()"];                       # Full repository history graph
        d = ["diff"];                                     # View line-by-line diff
        s = ["status"];                                   # Quick status check

        # Streamlined workflow shortcuts
        c = ["commit"];                                   # Standard commit + advance working copy
        sync = ["git" "fetch"];                           # Fetch latest remote references
        push = ["git" "push"];                            # Push bookmarks to remote

        # Quick branch/bookmark manipulation
        done = ["bookmark" "set" "main" "-r" "@"];       # Move 'main' bookmark to current working copy (@)
        nxt = ["new" "main"];                            # Open a fresh working copy on top of 'main'
      };

      ui = {
        editor = "emacs -nw"; # Adjust to your preferred editor
        paginate = "auto";
      };
    };
  };
}

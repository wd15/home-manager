# ============================================================
# git-ssh.nix  (laptop -- now just a passthrough)
# Nothing laptop-specific remains once .mambarc moved to shared;
# kept as its own file only so home.nix's existing imports list
# doesn't need editing.
# ============================================================
{ ... }:

{
  imports = [ ./git-ssh-common.nix ];
}

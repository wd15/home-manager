# ============================================================
# git-ssh-common.nix
# Shared between laptop and cluster: portable git dotfiles,
# keychain, and .mambarc (same Cloudflare Gateway proxy
# restriction applies from both machines' networks).
# ============================================================
{ ... }:

{
  home.file = {
    ".config/git/config".source = ./dotfiles/gitconfig;
    ".commit-template.txt".source = ./dotfiles/commit-template.txt;
    ".gitignore".source = ./dotfiles/gitignore;
    ".git-completion.bash".source = ./dotfiles/git-completion.bash;
    ".ssh/config".source = ./dotfiles/ssh-config;
    ".signature.txt".source = ./dotfiles/signature.txt;

    ".mambarc".text = ''
      channels:
        - conda-forge
      always_yes: true
      proxy_servers:
        http:  http://qv74thju04.proxy.cloudflare-gateway.com
        https: https://qv74thju04.proxy.cloudflare-gateway.com:443
    '';
  };

  programs.keychain = {
    enable = true;
    enableBashIntegration = true;
    keys = [ "id_ed25519" "id_rsa" ];
  };
}
